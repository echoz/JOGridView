//
//  gridviewAppDelegate.m
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "gridviewAppDelegate.h"

@implementation gridviewAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	[self.window makeKeyAndVisible];

	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	JOGridView *gridview = [[JOGridView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
	[self.window addSubview:gridview];
	gridview.debug = YES;
	gridview.delegate = self;
	gridview.datasource = self;
	[gridview reloadData];
	
	[gridview release];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

#pragma mark -
#pragma mark JOGridView Stuff

-(NSUInteger)rowsForGridView:(JOGridView *)gridView {
	return 100;
}

-(NSUInteger)columnsForGridView:(JOGridView *)gridView {
	return 3;
}

-(JOGridViewCell *)cellForGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"cell";
	
	JOGridViewCell *cell = [gridView dequeueReusableCellWithIdenitifer:identifier];
	
	if (!cell) {
		cell = [[JOGridViewCell alloc] init];
		cell.reuseIdentifier = @"cell";
	}
	
	return cell;
}

+ (UIColor *) randomColor
{
	CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

-(void)willDisplayCell:(JOGridViewCell *)cell forGridView:(JOGridView *)gridView atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [gridviewAppDelegate randomColor];
	cell.textLabel.text = [NSString stringWithFormat:@"%i:%i", indexPath.section, indexPath.row];
}


- (void)dealloc
{
	[_window release];
    [super dealloc];
}

@end
