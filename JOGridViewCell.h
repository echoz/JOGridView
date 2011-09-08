//
//  JOGridViewCell.h
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JOGridViewCell : UIView {
	NSString*	__reuseIdentifier;
	UILabel*	textLabel;
}
@property (readonly) UILabel *textLabel;
@property (nonatomic, copy) NSString *reuseIdentifier;

@end
