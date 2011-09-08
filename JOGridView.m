//
//  JOGridView.m
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JOGridView.h"
#import <QuartzCore/QuartzCore.h>

#define JOGRIDVIEW_DEFAULT_ROW_HEIGHT 44.0

@interface JOGridView (PrivateMethods)
-(void)enqueueReusableCell:(JOGridViewCell *)cell;
-(NSRange)rangeOfVisibleRows;
-(void)setFirstVisibleRow:(NSUInteger)row;

-(void)purgeCells;
-(void)buildCells;

-(CGFloat)heightRelativeToOriginForRow:(NSUInteger)row;
-(NSUInteger)rowForHeightRelativeToOrigin:(CGFloat)height;

// delegate datasource single point of entry
-(CGFloat)delegateHeightForRow:(NSUInteger)row;
-(JOGridViewCell *)dataSourceCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)delegateWillDisplayCell:(JOGridViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation JOGridView
@synthesize datasource = gridViewDataSource, delegate = gridViewDelegate;
@synthesize debug;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
		__visibleRows = [[NSMutableArray alloc] initWithCapacity:0];
		__rows = 0;
		__previousOffset = 0.0;
		
		__dataSourceDirty = YES;
		
		__firstWarpedInRow = 0;
		__firstWarpedInRowHeight = 0.0;
		
		__lastWarpedInRow = 0;
		__lastWarpedInRowHeight = 0.0;
		
		self.alwaysBounceVertical = YES;
		self.showsVerticalScrollIndicator = YES;
		self.showsHorizontalScrollIndicator = NO;
		
		self.canCancelContentTouches = NO;
		self.clipsToBounds = YES;
		self.pagingEnabled = NO;
		self.scrollEnabled = YES;	
		
		[super setDelegate:self];
		
		debugInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 10 - 22.0, 100.0, 22.0)];
		debugInfoLabel.textAlignment = UITextAlignmentCenter;
		debugInfoLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		debugInfoLabel.backgroundColor = [UIColor whiteColor];
		debugInfoLabel.textColor = [UIColor blackColor];
		debugInfoLabel.layer.cornerRadius = 5.0;
		debugInfoLabel.font = [UIFont systemFontOfSize:10.0];
	}

    return self;
}

-(void)dealloc {
	[__reusableViews release], __reusableViews = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Override Accessors

-(void)setDatasource:(id<JOGridViewDataSource>)datasource {
	if (datasource != gridViewDataSource) {
		gridViewDataSource = datasource;
		__dataSourceDirty = YES;
	}
}

#pragma mark -
#pragma mark View/s

-(void)purgeCells {
	[__visibleRows removeAllObjects];
	[__reusableViews removeAllObjects];
	
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
}

-(void)buildCells {
	// figure out the visible rows
	
	__firstWarpedInRow = [self rowForHeightRelativeToOrigin:self.contentOffset.y];
	__firstWarpedInRowHeight = [self heightRelativeToOriginForRow:__firstWarpedInRow];
	
	// lets find the last row
	CGFloat adjustedOffset = self.contentOffset.y + (self.contentOffset.y - __firstWarpedInRowHeight);
	NSUInteger startrow = __firstWarpedInRow;
	
	while ((adjustedOffset < (self.contentOffset.y + self.frame.size.height)) && (startrow < __rows)) {
		adjustedOffset += [self delegateHeightForRow:startrow];
		startrow++;
	}
	
	__lastWarpedInRow = startrow-1;
	__lastWarpedInRowHeight = [self heightRelativeToOriginForRow:__lastWarpedInRow];
	
	if (__dataSourceDirty) {
		// if the data source is dirty, it means we must purge all existing
		// cells and recreate them in the view hierachy
		
		__dataSourceDirty = NO;
		[self purgeCells];
		
		JOGridViewCell *cell = nil;
		NSMutableArray *rowArray = nil;
		
		for (NSUInteger i=__firstWarpedInRow;i<__lastWarpedInRow+1;i++) {
			
			rowArray = [NSMutableArray arrayWithCapacity:__columns];
			
			for (NSUInteger q=0;q<__columns;q++) {
				cell = [self dataSourceCellAtIndexPath:[NSIndexPath indexPathForRow:q inSection:i]];
				
				[self delegateWillDisplayCell:cell atIndexPath:[NSIndexPath indexPathForRow:q inSection:i]];
				
				[rowArray addObject:cell];
				
				if (!cell.superview) {
					[self addSubview:cell];
				}

				
				cell.frame = CGRectMake(-CGFLOAT_MAX, -CGFLOAT_MAX, 0, 0);
			}
			
			[__visibleRows addObject:rowArray];
		}
		
		if (self.debug) {			
			[self.superview addSubview:debugInfoLabel];
		} else {
			[debugInfoLabel removeFromSuperview];
		}
				
	} 
	
	// layout the cells
	
	CGFloat startHeight = __firstWarpedInRowHeight;
	CGFloat rowHeight = 0.0;
	JOGridViewCell *cell = nil;
	
	for (NSUInteger i=0;i<[__visibleRows count];i++) {
		rowHeight = [self delegateHeightForRow:__firstWarpedInRow + i];
		
		for (NSUInteger q=0;q<[[__visibleRows objectAtIndex:i] count];q++) {
			cell = [[__visibleRows objectAtIndex:i] objectAtIndex:q];
			
			cell.frame = CGRectMake(q * (self.frame.size.width / __columns), startHeight, self.frame.size.width / __columns, rowHeight);
		}
		
		startHeight += rowHeight;
	}
	
}

-(void)layoutRow:(NSUInteger)row atHeight:(CGFloat)height scrollingUp:(BOOL)scrollingUp {
	
	CGFloat rowHeight = [self delegateHeightForRow:row];
				
	JOGridViewCell *cell = nil;
	
	NSMutableArray *rowOfCells = [NSMutableArray arrayWithCapacity:__columns];
	
	for (NSUInteger i=0;i<__columns;i++) {
		cell = [self dataSourceCellAtIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];

		[self delegateWillDisplayCell:cell atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		
		if (!cell.superview) {
			[self addSubview:cell];			
		}
		
		cell.frame = CGRectMake(i * (self.frame.size.width / __columns), height, self.frame.size.width / __columns, rowHeight);
		[cell layoutSubviews];
		
		[rowOfCells addObject:cell];
	}
	
	if (scrollingUp) {
		[__visibleRows addObject:rowOfCells];
	} else {
		[__visibleRows insertObject:rowOfCells atIndex:0];
	}
}

-(void)layoutSubviews {
	BOOL scrollingDownwards = (__previousOffset > self.contentOffset.y) ? YES : NO;
	
	//	NSLog(@"views in scrollview: %i", [self.subviews count]);
	if (self.debug) {
		debugInfoLabel.text = [NSString stringWithFormat:@"cells in view: %i", [self.subviews count]];		
	}
	
	if ([gridViewDataSource conformsToProtocol:@protocol(JOGridViewDataSource)]) {
		if (scrollingDownwards) {
			// scrolling down
			
			// decide if we are even gonna warp in new rows
			
			while ((__firstWarpedInRow > 0) && (self.contentOffset.y <= __firstWarpedInRowHeight)) {
				// lets warp in a row!
				__firstWarpedInRow--;
				__firstWarpedInRowHeight = [self heightRelativeToOriginForRow:__firstWarpedInRow];
				
				[self layoutRow:__firstWarpedInRow
					   atHeight:__firstWarpedInRowHeight
					scrollingUp:NO];
				
			}
			
			// decide if we need to warp out a row that's now hidden
			
			while (([__visibleRows count] > 0) && ((self.contentOffset.y + self.frame.size.height) <= __lastWarpedInRowHeight)) {
				NSArray *rowToEnqueue = [[__visibleRows lastObject] retain];
				[__visibleRows removeLastObject];
				
				for (JOGridViewCell *cell in rowToEnqueue) {
					[self enqueueReusableCell:cell];
				}
				[rowToEnqueue release];
				
				__lastWarpedInRow--;
				__lastWarpedInRowHeight = [self heightRelativeToOriginForRow:__lastWarpedInRow];
			}
			
		} else {
			// scrolling up
			
			while ((__lastWarpedInRow < __rows-1) && ((self.contentOffset.y + self.frame.size.height) >= (__lastWarpedInRowHeight + [self delegateHeightForRow:__lastWarpedInRow]))) {
				
				__lastWarpedInRow++;
				__lastWarpedInRowHeight = [self heightRelativeToOriginForRow:__lastWarpedInRow];
				
				[self layoutRow:__lastWarpedInRow
					   atHeight:__lastWarpedInRowHeight
					scrollingUp:YES];
				
			}
			
			// deal with enqueueing
			while (([__visibleRows count] > 0) && (self.contentOffset.y >= (__firstWarpedInRowHeight + [self delegateHeightForRow:__firstWarpedInRow]))) {
				
				NSArray *rowToEnqueue = [[__visibleRows objectAtIndex:0] retain];
				[__visibleRows removeObjectAtIndex:0];
				
				for (JOGridViewCell *cell in rowToEnqueue) {
					[self enqueueReusableCell:cell];
				}
				
				[rowToEnqueue release];
				
				__firstWarpedInRow++;
				__firstWarpedInRowHeight = [self heightRelativeToOriginForRow:__firstWarpedInRow];
				
			}				
			
			
		}	
	}
	
	__previousOffset = self.contentOffset.y;
}

-(NSUInteger)rowForHeightRelativeToOrigin:(CGFloat)height {
	
	// find out the row that the current height represents all the way from the
	// origin of the content view. if the height is exactly the height of the 
	// row or less than the height, it is that row

	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {

		CGFloat calcheight = 0.0;
		int row=0;
		
		while (calcheight < height) {
			calcheight += [gridViewDelegate gridView:self heightForRow:row];			
			row++;
		}
					
		if (calcheight > height) {
			return row-1;
		} else {
			return row;
		}		
		
	} else {
		
		return (NSUInteger)(height / JOGRIDVIEW_DEFAULT_ROW_HEIGHT);			
		
	}
}

-(CGFloat)heightRelativeToOriginForRow:(NSUInteger)row {
	
	// returns the height for the row accurate to its full height from the 
	// origin to the end of the row.
	
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		CGFloat height = 0.0;
		
		for (NSUInteger i=0;i<row;i++) {
			height += [gridViewDelegate gridView:self heightForRow:i];
		}
		
		return height;
	} else {
		return (row * JOGRIDVIEW_DEFAULT_ROW_HEIGHT);
	}
}

#pragma mark -
#pragma mark Data

-(void)reloadData {

	if ([gridViewDataSource conformsToProtocol:@protocol(JOGridViewDataSource)]) {
		
		__rows = [gridViewDataSource rowsForGridView:self];
		__columns = [gridViewDataSource columnsForGridView:self];
		
		// gather total height
		CGFloat totalHeight = 0.0;
		
		if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
			for (NSUInteger i=0;i<__rows;i++) {
				totalHeight += [gridViewDelegate gridView:self heightForRow:i];
			}				
		} else {
			totalHeight = __rows * JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
		}
		
		self.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
		
		[self buildCells];
		
	} else {
		NSLog(@"Y U NO CONFIRM TO PROPER REQUIRED PROTOCOL?");
		
	}

}

#pragma mark -
#pragma mark Reusable Views

-(JOGridViewCell *)dequeueReusableCellWithIdenitifer:(NSString *)identifier {

	NSMutableArray *stack = [__reusableViews objectForKey:identifier];
	
	if ([stack count] > 0) {
		
		JOGridViewCell *view = [stack objectAtIndex:0];
		[stack removeObjectAtIndex:0];

		return view;
	} else {
		return nil;
	}
}

-(void)enqueueReusableCell:(JOGridViewCell *)cell {

	cell.frame = CGRectMake(-CGFLOAT_MAX, -CGFLOAT_MAX, 0, 0);
	
	if ([__reusableViews objectForKey:cell.reuseIdentifier]) {
		[[__reusableViews objectForKey:cell.reuseIdentifier] addObject:cell];

	} else {
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
		[array addObject:cell];
		[__reusableViews setObject:array forKey:cell.reuseIdentifier];
	}

}


#pragma mark -
#pragma mark Delegate/Datasource Methods

// inspired by Peter Steinberger's article at
// http://petersteinberger.com/2011/09/fast-and-elegant-delegation-in-objective-c/
// keeps things clean

-(CGFloat)delegateHeightForRow:(NSUInteger)row {
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		return [gridViewDelegate gridView:self heightForRow:row];
	} else {
		return JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
	}
}

-(JOGridViewCell *)dataSourceCellAtIndexPath:(NSIndexPath *)indexPath {
	if ([gridViewDataSource respondsToSelector:@selector(cellForGridView:atIndexPath:)]) {
		return [gridViewDataSource cellForGridView:self atIndexPath:indexPath];
	} else {
		return nil;
	}
}

-(void)delegateWillDisplayCell:(JOGridViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if ([gridViewDelegate respondsToSelector:@selector(willDisplayCell:forGridView:atIndexPath:)]) {
		[gridViewDelegate willDisplayCell:cell forGridView:self atIndexPath:indexPath];
	}
}


@end
