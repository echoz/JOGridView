//
//  JOGridView.m
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JOGridView.h"

@implementation JOGridView
@synthesize datasource;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		__reusableViews = [[NSMutableDictionary alloc] initWithCapacity:0];
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
		externalDelegate = delegate;
	}
	
	[super setDelegate:self];
}

-(id<JOGridViewDelegate, UIScrollViewDelegate>)delegate {
	return externalDelegate;
}

#pragma mark -
#pragma mark View

-(void)layoutSubviews {
	// layout subviews
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self) {
		
	}
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
