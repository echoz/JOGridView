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
-(void)enqueueReusableView:(UIView *)view withIdentifier:(NSString *)identifier;
@end

@implementation JOGridView
@synthesize datasource = gridViewDataSource;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
		__rows = 0;
		
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

#pragma mark -
#pragma mark View

-(void)layoutSubviews {
	// layout subviews
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self) {
		// do tracking of which rows are in view
	}
}

#pragma mark -
#pragma mark Data!

-(void)reloadData {

	if ([gridViewDataSource respondsToSelector:@selector(rowsForGridView:)]) {
		__rows = [gridViewDataSource rowsForGridView:self];
	}
	
	// gather total height
	CGFloat totalHeight = 0.0;
	
	if ([gridViewDataSource respondsToSelector:@selector(gridView:heightForRow:)]) {
		for (int i=0;i<__rows;i++) {
			totalHeight += [gridViewDataSource gridView:self heightForRow:i];
		}				
	} else {
		totalHeight = __rows * JOGRIDVIEW_DEFAULT_ROW_HEIGHT;
	}
	
	self.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
	
}

#pragma mark -
#pragma mark Reusable Views

-(UIView *)dequeueReusableViewWithIdenitifer:(NSString *)identifier {

	NSMutableArray *stack = [__reusableViews objectForKey:identifier];
	
	if ((stack) && ([stack count] > 0)) {
		
		UIView *view = [stack objectAtIndex:0];
		[stack removeObjectAtIndex:0];
		
		return view;
	} else {
		return nil;
	}
}

-(void)enqueueReusableView:(UIView *)view withIdentifier:(NSString *)identifier {
	if ([__reusableViews objectForKey:identifier]) {
		[[__reusableViews objectForKey:identifier] addObject:view];
	} else {
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
		[array addObject:view];
		[__reusableViews setObject:array forKey:identifier];
	}
}

@end
