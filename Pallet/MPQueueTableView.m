//
//  MPQueueTableView.m
//  Pallet
//
//  Created by Vasileios Georgitzikis on 16/7/10.
//  Copyright 2010 Tzikis. All rights reserved.
//

#import "MPQueueTableView.h"


@implementation MPQueueTableView


-(void)keyDown:(NSEvent *)theEvent {
	if ([[theEvent characters] characterAtIndex:0] == NSDeleteCharacter || [[theEvent characters] characterAtIndex:0] == NSBackspaceCharacter)
	{
		NSLog(@"Deleting a queue entry");
		NSLog(@"Selection: %i", [queue selectionIndex]);
		if([queue selectionIndex]>=0) [queue removeObjectAtArrangedObjectIndex:[queue selectionIndex]];
	}
	else
	{
        [super keyDown:theEvent];
	}

}

@end
