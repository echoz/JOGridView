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
@end

@implementation JOGridView
@synthesize datasource = gridViewDataSource;
@synthesize cellSpacing = __cellSpacing;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
		__rows = 0;
		__firstVisibleRow = 0;
		__firstVisibleRowHeight = 0.0;
		__leadInHeight = 0.0;
		__previousOffset = 0.0;
		
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

-(id<JOGridViewDelegate, UIScrollViewDelegate>)delegate {
	return gridViewDelegate;
}

-(void)setFirstVisibleRow:(NSUInteger)row {
	__firstVisibleRow = row;

	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		__firstVisibleRowHeight = [gridViewDelegate gridView:self heightForRow:row];
	} else {
		__firstVisibleRowHeight = JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
	}
}

#pragma mark -
#pragma mark Views

-(void)layoutSubviews {
	// layout subviews
	
}

-(void)layoutRow:(NSUInteger)row atHeight:(CGFloat)height scrollingUp:(BOOL)scrollingUp {
	BOOL shouldFillRow = NO;
	
	// enquire if we need to fill the row with whatever number of columns we have
	if ([gridViewDelegate respondsToSelector:@selector(gridView:shouldFillColumnsAtRow:)]) {
		shouldFillRow = [gridViewDelegate gridView:self shouldFillColumnsAtRow:row];
	}
	
	CGFloat rowHeight = 0.0;
	
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		// find height or starting point of where to add the new row
		rowHeight = [gridViewDelegate gridView:self heightForRow:row];
	} else {
		rowHeight = JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
	}
	
	NSUInteger cols = 0;
	NSUInteger maxcols = [gridViewDataSource maxColumnsForGridView:self];
	NSUInteger widthModifier = maxcols;
	
	if ([gridViewDataSource respondsToSelector:@selector(columnsForGridView:atRow:)]) {
		cols = [gridViewDataSource columnsForGridView:self atRow:row];
		if (shouldFillRow) {
			widthModifier = cols;
		}
	} else {
		cols = maxcols;
	}
	
	JOGridViewCell *cell = nil;
	
	NSMutableArray *rowOfCells = [NSMutableArray arrayWithCapacity:cols];
	
	for (int i=0;i<cols;i++) {
		cell = [gridViewDataSource cellForGridView:self atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		if ([gridViewDelegate respondsToSelector:@selector(willDisplayCell:forGridView:atIndexPath:)]) {
			[gridViewDelegate willDisplayCell:cell forGridView:self atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		}

		[self addSubview:cell];
		
		cell.frame = CGRectMake(i/widthModifier * self.frame.size.width, height - rowHeight, self.frame.size.width / widthModifier, rowHeight);
		
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
		BOOL scrollingDownwards = (__previousOffset < self.contentOffset.y) ? YES : NO;

		if (scrollingDownwards) {
			// scrolling down
			
			// add new row!			
			if ((__leadInHeight - self.contentOffset.y) <= 0) {
				[self layoutRow:(__firstVisibleRow-1) atHeight:self.contentOffset.y scrollingUp:NO];
				[self setFirstVisibleRow:__firstVisibleRow-1];
			}
			
			// enqueue if you must
			
			
		} else {
			// scrolling up
			
			// figure out number of visible rows (partial or not)
			CGFloat visibleAreaHeight = self.frame.size.height + self.contentOffset.y - __leadInHeight;
			CGFloat visibleRowsHeight = 0.0;
			
			NSUInteger row = __firstVisibleRow;
			
			// add new rows if there is a need
			while (visibleRowsHeight < visibleAreaHeight) {
				if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
					visibleRowsHeight += [gridViewDelegate gridView:self heightForRow:row];
				} else {
					visibleRowsHeight += JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
				}
				row++;
			}
			
			// returns total number of supposedly visible rows
			NSUInteger rows = (row - __firstVisibleRow) + 1;
			
			// check if we need to warp in new rows
			if ((rows > [__visibleRows count]) && (rows == __rows)) {
				[self layoutRow:row atHeight:(visibleRowsHeight + self.contentOffset.y) scrollingUp:YES];
			}
	
			// enqueue if you must
			if ((__leadInHeight + __firstVisibleRowHeight) >= self.contentOffset.y) {
				// enqueue!
				NSArray *row = [__visibleRows objectAtIndex:0];
				[__visibleRows removeObject:0];
				
				for (JOGridViewCell *cell in row) {
					[self enqueueReusableCell:cell];
				}
				
				[self setFirstVisibleRow:__firstVisibleRow+1];
			}
			
		}
	}
	
	__previousOffset = self.contentOffset.y;
}

-(NSRange)rangeOfVisibleRows {
	
	NSUInteger rows = 0;
	__firstVisibleRow = 0;
	__leadInHeight = 0.0;
	
	if (self.frame.size.height == 0.0) {
		
		// if the frame's height is zero means nothing is visible
		__firstVisibleRow = 0;
		rows = 0;
		
	} else {
		
		// find where the visible/semi visible row starts from
		while (__leadInHeight < self.contentOffset.y) {
			if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
				__leadInHeight += [gridViewDelegate gridView:self heightForRow:__firstVisibleRow];
			} else {
				__leadInHeight += JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
			}
			[self setFirstVisibleRow:__firstVisibleRow+1];
		}
		
		// leadInHeight is the height of the completely non visible portion
		// hence it wil always be one less row than the last row
		if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
			__leadInHeight -= [gridViewDelegate gridView:self heightForRow:__firstVisibleRow];
		} else {
			__leadInHeight -= JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
		}
		
		// find the number of sequentially visible rows
		CGFloat visibleAreaHeight = self.frame.size.height + self.contentOffset.y - __leadInHeight;
		CGFloat visibleRowsHeight = 0.0;
		
		rows = __firstVisibleRow;
		
		while (visibleRowsHeight < visibleAreaHeight) {
			if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
				visibleRowsHeight += [gridViewDelegate gridView:self heightForRow:rows];
			} else {
				visibleRowsHeight += JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
			}
			rows++;
		}
		
		rows = (rows - __firstVisibleRow) + 1;
	}
	
	return NSMakeRange(__firstVisibleRow, rows);
}

#pragma mark -
#pragma mark Data

-(void)reloadData {

	if ([gridViewDataSource respondsToSelector:@selector(rowsForGridView:)]) {
		__rows = [gridViewDataSource rowsForGridView:self];
	}
	
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
}

#pragma mark -
#pragma mark Reusable Views

-(UIView *)dequeueReusableCellWithIdenitifer:(NSString *)identifier {

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

@end
