//
//  JOGridView.m
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JOGridView.h"

#define JOGRIDVIEW_DEFAULT_ROW_HEIGHT 44.0

@interface JOGridView (PrivateMethods)
-(void)enqueueReusableCell:(JOGridViewCell *)cell;
-(NSRange)rangeOfVisibleRows;
-(void)setFirstVisibleRow:(NSUInteger)row;

-(CGFloat)heightForRow:(NSUInteger)row;
-(NSUInteger)rowForHeight:(CGFloat)height;

// delegate datasource single point of entry
-(CGFloat)delegateHeightForRow:(NSUInteger)row;
-(JOGridViewCell *)dataSourceCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)delegateWillDisplayCell:(JOGridViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation JOGridView
@synthesize datasource = gridViewDataSource;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
		__rows = 0;
		__previousOffset = 0.0;
		
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
	}

    return self;
}

-(void)dealloc {
	[__reusableViews release], __reusableViews = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Override Accessors

-(void)setDelegate:(id<JOGridViewDelegate, UIScrollViewDelegate>)delegate {
	if (delegate != (id<JOGridViewDelegate, UIScrollViewDelegate>)self) {
		gridViewDelegate = delegate;
	}
	
	[super setDelegate:self];
}

-(id<JOGridViewDelegate>)delegate {
	return gridViewDelegate;
}

#pragma mark -
#pragma mark Views

-(void)layoutSubviews {
	// layout subviews
	
}

-(void)layoutRow:(NSUInteger)row atHeight:(CGFloat)height scrollingUp:(BOOL)scrollingUp {
	
	CGFloat rowHeight = [self delegateHeightForRow:row];
		
	NSUInteger cols = [gridViewDataSource columnsForGridView:self];
		
	JOGridViewCell *cell = nil;
	
	NSMutableArray *rowOfCells = [NSMutableArray arrayWithCapacity:cols];
	
	for (int i=0;i<cols;i++) {
		cell = [self dataSourceCellAtIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];

		[self delegateWillDisplayCell:cell atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		
		[self addSubview:cell];
		
		cell.frame = CGRectMake(i/cols * self.frame.size.width, height - rowHeight, self.frame.size.width / cols, rowHeight);
		
		[rowOfCells addObject:cell];
	}
	
	if (scrollingUp) {
		[__visibleRows addObject:rowOfCells];
	} else {
		[__visibleRows insertObject:rowOfCells atIndex:0];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (scrollView == self) {
		BOOL scrollingDownwards = (__previousOffset > self.contentOffset.y) ? YES : NO;

		if (scrollingDownwards) {
			// scrolling down

			// decide if we are even gonna warp in new rows
			if (__firstWarpedInRow > 0) {
				
				if (self.contentOffset.y <= __firstWarpedInRowHeight) {
					// lets warp in a row!
					__firstWarpedInRow--;
					__firstWarpedInRowHeight = [self heightForRow:__firstWarpedInRow];

					[self layoutRow:__firstWarpedInRow
						   atHeight:__firstWarpedInRowHeight
						scrollingUp:NO];
					
				}
			}
			
			// decide if we need to warp out a row that's now hidden
			if (__lastWarpedInRow < __rows) {
				if ((__lastWarpedInRowHeight - [self delegateHeightForRow:__lastWarpedInRow]) <= (self.contentOffset.y + self.frame.size.height)) {
					NSArray *rowToEnqueue = [__visibleRows lastObject];
					[__visibleRows removeLastObject];
					
					for (JOGridViewCell *cell in rowToEnqueue) {
						[self enqueueReusableCell:cell];
					}
					
					__lastWarpedInRow--;
					__lastWarpedInRowHeight = [self heightForRow:__lastWarpedInRow];
				}
				
			}
			
		} else {
			// scrolling up

			if (__lastWarpedInRow < __rows) {
				
				if (__lastWarpedInRowHeight >= (self.contentOffset.y + self.frame.size.height)) {
					
					__lastWarpedInRow++;
					__lastWarpedInRowHeight = [self heightForRow:__lastWarpedInRow];
					
					[self layoutRow:__lastWarpedInRow
						   atHeight:__lastWarpedInRowHeight
						scrollingUp:YES];
					
				}
			}
			
			// deal with enqueueing
			
			if (__firstWarpedInRow > 0) {
				if ((__firstWarpedInRowHeight - [self delegateHeightForRow:__firstWarpedInRow]) >= self.contentOffset.y) {
					NSArray *rowToEnqueue = [__visibleRows objectAtIndex:0];
					[__visibleRows removeObjectAtIndex:0];
					
					for (JOGridViewCell *cell in rowToEnqueue) {
						[self enqueueReusableCell:cell];
					}
					
					__firstWarpedInRow++;
					__firstWarpedInRowHeight = [self heightForRow:__firstWarpedInRow];
					
				}				
			}
			
			
		}
		__previousOffset = self.contentOffset.y;
	}
	
}


-(NSUInteger)rowForHeight:(CGFloat)height {
	
	// find out the row that the current height represents all the way from the
	// origin of the content view. if the height is exactly the height of the 
	// row or less than the height, it is that row

	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {

		CGFloat calcheight = 0.0;
		int i=0;
		
		while (calcheight < height) {
			calcheight += [gridViewDelegate gridView:self heightForRow:i];			
			i++;
		}
					
		if (calcheight >= height) {
			return i;
		} else {
			return 0;
		}		
		
	} else {
		return (NSUInteger)(height / JOGRIDVIEW_DEFAULT_ROW_HEIGHT);
	}
}

-(CGFloat)heightForRow:(NSUInteger)row {
	
	// returns the height for the row accurate to its full height from the 
	// origin to the end of the row.
	
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		CGFloat height = 0.0;
		
		for (int i=0;i<row;i++) {
			height += [gridViewDelegate gridView:self heightForRow:i];
		}
		
		return height;
	} else {
		return (__rows * JOGRIDVIEW_DEFAULT_ROW_HEIGHT);
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
			for (int i=0;i<__rows;i++) {
				totalHeight += [gridViewDelegate gridView:self heightForRow:i];
			}				
		} else {
			totalHeight = __rows * JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
		}
		
		self.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
		
		[self setNeedsLayout];
		
		// TODO: warp in cells for current view		

		
	} else {
		NSLog(@"Y U NO CONFIRM TO PROPER REQUIRED PROTOCOL?");
		
	}

}

#pragma mark -
#pragma mark Reusable Views

-(JOGridViewCell *)dequeueReusableCellWithIdenitifer:(NSString *)identifier {

	NSMutableArray *stack = [__reusableViews objectForKey:identifier];
	
	if ((stack) && ([stack count] > 0)) {
		
		JOGridViewCell *view = [stack objectAtIndex:0];
		[stack removeObjectAtIndex:0];
		
		return view;
	} else {
		return nil;
	}
}

-(void)enqueueReusableCell:(JOGridViewCell *)cell {
	
	cell.frame = CGRectMake(-CGFLOAT_MAX, -CGFLOAT_MAX, cell.frame.size.width, cell.frame.size.height);
	
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
