//
//  gridviewAppDelegate.h
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOGridView.h"

@interface gridviewAppDelegate : NSObject <UIApplicationDelegate, JOGridViewDataSource, JOGridViewDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
