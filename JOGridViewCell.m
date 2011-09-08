//
//  JOGridViewCell.m
//  gridview
//
//  Created by Jeremy Foo on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JOGridViewCell.h"

@implementation JOGridViewCell
@synthesize reuseIdentifier = __reuseIdentifier;
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.clipsToBounds = YES;
		
		textLabel = [[UILabel alloc] initWithFrame:frame];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.textColor = [UIColor blackColor];
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.text = @"";

		[self addSubview:textLabel];

    }
    return self;
}

-(void) dealloc {
	[__reuseIdentifier release], __reuseIdentifier = nil;
	[textLabel release], textLabel = nil;
	[super dealloc];
}

-(void)layoutSubviews {
	textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
