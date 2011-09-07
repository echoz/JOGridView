//
//  JOGridView.h
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOGridView;

@protocol JOGridViewDelegate <NSObject, UIScrollViewDelegate>
@optional
-(void)willDisplayView:(UIView *)view forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol JOGridViewDataSource <NSObject>
@optional
-(CGFloat)gridView:(JOGridView *)gridview heightForRow:(NSUInteger)row;
@required
-(NSUInteger)rowsForGridView:(JOGridView *)gridView;
-(NSUInteger)columnsForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
-(UIView *)viewForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@interface JOGridView : UIScrollView <UIScrollViewDelegate> {
	
	NSUInteger __rows;
	
	NSMutableDictionary *__reusableViews;
	
	id <JOGridViewDelegate> gridViewDelegate;
	id <JOGridViewDataSource> gridViewDataSource;
}
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;

-(UIView *)dequeueReusableViewWithIdenitifer:(NSString *)identifier;
-(void)reloadData;

@end
