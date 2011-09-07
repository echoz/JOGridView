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

@protocol JOGridViewDelegate <NSObject, UIScrollViewDelegate>
@optional
-(void)willDisplayCell:(JOGridViewCell *)cell forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)gridView:(JOGridView *)gridview heightForRow:(NSUInteger)row;
@end

@protocol JOGridViewDataSource <NSObject>

@required
-(NSUInteger)rowsForGridView:(JOGridView *)gridView;
-(NSUInteger)columnsForGridView:(JOGridView *)gridView;
-(JOGridViewCell *)cellForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@interface JOGridView : UIScrollView <UIScrollViewDelegate> {
	
	
	CGFloat __previousOffset;
	
	NSUInteger __rows;
	NSUInteger __columns;
	
	CGFloat __cellSpacing;
	
	NSMutableArray *__visibleRows;
	NSCache *__reusableViews;
	
	id <JOGridViewDelegate> gridViewDelegate;
	id <JOGridViewDataSource> gridViewDataSource;
}
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;
@property (nonatomic, assign) CGFloat cellSpacing;

-(JOGridViewCell *)dequeueReusableCellWithIdenitifer:(NSString *)identifier;
-(void)reloadData;

@end
