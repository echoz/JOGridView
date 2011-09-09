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

@interface JOGridView : UIScrollView {
	
	// debug
	
	BOOL					debug;
	UILabel*				debugInfoLabel;
	
	// cached data
	
	NSUInteger				__rows;
	NSUInteger				__columns;
	
	NSUInteger				__firstWarpedInRow;
	CGFloat					__firstWarpedInRowHeight;
	NSUInteger				__lastWarpedInRow;
	CGFloat					__lastWarpedInRowHeight;
	
    // configuration
    
    BOOL                    allowsSelection;
    
    
	// ivar properties
	
	CGFloat					__previousOffset;
	BOOL					__dataSourceDirty;
	
	NSMutableArray*			__visibleRows;
	NSMutableDictionary*	__reusableViews;
	
	id <JOGridViewDelegate> gridViewDelegate;
	id <JOGridViewDataSource> gridViewDataSource;
}
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;
@property (nonatomic, assign) id <JOGridViewDelegate> delegate;
@property (readwrite) BOOL debug;

// cell accessors
@property (readonly) NSArray *visibleRows;
-(NSIndexPath *)indexPathForCell:(JOGridViewCell *)cell;
-(NSIndexPath *)indexPathsForVisibleCells;
-(JOGridViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// selections
@property (readwrite) BOOL allowsSelecton;
-(NSIndexPath *)indexPathForSelectedCell;
-(void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
-(void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

// scrolling
-(void)scrollToRow:(NSUInteger)row animated:(BOOL)animated;
-(void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

// gridview properties
-(NSUInteger)numberOfRows;
-(NSUInteger)numberOfColumnsInRow:(NSUInteger)row;

// reload methods
-(JOGridViewCell *)dequeueReusableCellWithIdenitifer:(NSString *)identifier;
-(void)reloadData;
-(void)reloadCellAtIndexPath:(NSIndexPath *)indexPath;
-(void)reloadRow:(NSUInteger)row;

@end
