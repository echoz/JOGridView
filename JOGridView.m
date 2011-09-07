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
-(NSUInteger)rowForOffset:(CGFloat)offset;
@end

@implementation JOGridView
@synthesize datasource = gridViewDataSource;
@synthesize cellSpacing = __cellSpacing;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
		__rows = 0;
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

-(id<JOGridViewDelegate>)delegate {
	return gridViewDelegate;
}

#pragma mark -
#pragma mark Views

-(void)layoutSubviews {
	// layout subviews
	
}

-(void)layoutRow:(NSUInteger)row atHeight:(CGFloat)height scrollingUp:(BOOL)scrollingUp {
	
	CGFloat rowHeight = 0.0;
	
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {
		// find height or starting point of where to add the new row
		rowHeight = [gridViewDelegate gridView:self heightForRow:row];
	} else {
		rowHeight = JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
	}
	
	NSUInteger cols = [gridViewDataSource columnsForGridView:self];
		
	JOGridViewCell *cell = nil;
	
	NSMutableArray *rowOfCells = [NSMutableArray arrayWithCapacity:cols];
	
	for (int i=0;i<cols;i++) {
		cell = [gridViewDataSource cellForGridView:self atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		if ([gridViewDelegate respondsToSelector:@selector(willDisplayCell:forGridView:atIndexPath:)]) {
			[gridViewDelegate willDisplayCell:cell forGridView:self atIndexPath:[NSIndexPath indexPathForRow:i inSection:row]];
		}

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
		BOOL scrollingDownwards = (__previousOffset < self.contentOffset.y) ? YES : NO;

		if (scrollingDownwards) {
			// scrolling down

			
		} else {
			// scrolling up

			
		}
		__previousOffset = self.contentOffset.y;
	}
	
}

-(NSUInteger)rowForOffset:(CGFloat)offset {
	
	if ([gridViewDelegate respondsToSelector:@selector(gridView:heightForRow:)]) {

		CGFloat height = 0.0;
		int i=0;
		
		while (height < offset) {
			height += [gridViewDelegate gridView:self heightForRow:i];			
			i++;
		}
					
		if (height >= offset) {
			return i;
		} else {
			return 0;
		}		
		
	} else {
		return (NSUInteger)(offset / JOGRIDVIEW_DEFAULT_ROW_HEIGHT);
	}
}

-(CGFloat)heightForRow:(NSUInteger)row {
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
		
	} else {
		NSLog(@"Y U NO CONFIRM TO PROPER REQUIRED PROTOCOL?");
		
	}

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
