//
//  MPCheckbox.m
//  Pallet
//
//  Created by Vasileios Georgitzikis on 21/7/10.
//  Copyright 2010 Tzikis. All rights reserved.
//

#import "MPCheckbox.h"


@implementation MPCheckbox

@synthesize isDefault, conflictsWith;

-(void) performClick: (id) sender
{
	NSLog(@"performing click");
	[super performClick:sender];
	NSLog(@"click performed");
}
@end
