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
-(void)willDisplayView:(UIView *)view forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
-(BOOL)gridView:(JOGridView *)gridview shouldFillColumnsAtRow:(NSUInteger)row;
-(CGFloat)gridView:(JOGridView *)gridview heightForRow:(NSUInteger)row;
@end

@protocol JOGridViewDataSource <NSObject>
@optional
-(NSUInteger)columnsForGridView:(JOGridView *)gridView atRow:(NSUInteger)row;

@required
-(NSUInteger)rowsForGridView:(JOGridView *)gridView;
-(NSUInteger)maxColumnsForGridView:(JOGridView *)gridView;
-(JOGridViewCell *)cellForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@interface JOGridView : UIScrollView <UIScrollViewDelegate> {
	
	NSUInteger __rows;
	CGFloat __cellSpacing;
	
	NSMutableDictionary *__reusableViews;
	
	id <JOGridViewDelegate> gridViewDelegate;
	id <JOGridViewDataSource> gridViewDataSource;
}
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;
@property (nonatomic, assign) CGFloat cellSpacing;

-(UIView *)dequeueReusableCellWithIdenitifer:(NSString *)identifier;
-(void)reloadData;

@end
