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
-(void)willDisplayView:(UIView *)view forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol JOGridViewDataSource <NSObject>
@required
-(NSUInteger)rowsForGridView:(JOGridView *)gridView;
-(NSUInteger)columnsForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
-(UIView *)viewForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath;
@end

@interface JOGridView : UIScrollView <UIScrollViewDelegate> {
	NSMutableDictionary *__reusableViews;
	
	id <JOGridViewDelegate> externalDelegate;
	id <JOGridViewDataSource> datasource;
}
@property (nonatomic, assign) id<JOGridViewDataSource> datasource;

-(UIView *)dequeueReusableViewWithIdenitifer:(NSString *)identifier;

@end
