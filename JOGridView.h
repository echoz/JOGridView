//
//  JOGridView.h
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOGridViewCell.h"

@class JOGridView;

/// Delegate

@protocol JOGridViewDelegate <NSObject, UIScrollViewDelegate>
@optional
-(void)willDisplayCell:(JOGridViewCell *)cell forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)gridView:(JOGridView *)gridview heightForRow:(NSUInteger)row;
@end

/// Data Sources are required

@protocol JOGridViewDataSource <NSObject>
@required
-(NSUInteger)rowsForGridView:(JOGridView *)gridView;
-(NSUInteger)columnsForGridView:(JOGridView *)gridView;
-(JOGridViewCell *)cellForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@interface JOGridView : UIScrollView <UIScrollViewDelegate> {
	
	BOOL					debug;
	UILabel*				debugInfoLabel;
	
	NSUInteger				__firstWarpedInRow;
	CGFloat					__firstWarpedInRowHeight;
	NSUInteger				__lastWarpedInRow;
	CGFloat					__lastWarpedInRowHeight;
	
	CGFloat					__previousOffset;
	
	NSUInteger				__rows;
	NSUInteger				__columns;
	
	BOOL					__dataSourceDirty;
	
	NSMutableArray*			__visibleRows;
	NSMutableDictionary*	__reusableViews;
	
	id <JOGridViewDelegate> gridViewDelegate;
	id <JOGridViewDataSource> gridViewDataSource;
}
@property (readwrite) BOOL debug;
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;

-(JOGridViewCell *)dequeueReusableCellWithIdenitifer:(NSString *)identifier;
-(void)reloadData;

@end
