//
//  MPPortTableView.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 7/14/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPPortTableView.h"


@implementation MPPortTableView

-(id)init {
    [quickLookPanel setFloatingPanel:YES];
    
	[super init];
    return self;
}

-(void)keyDown:(NSEvent *)theEvent {
    if ([[theEvent characters] characterAtIndex:0] == ' ' ||
        ([[theEvent characters] characterAtIndex:0] == 27 && [quickLookPanel isVisible])) {
        if ([quickLookPanel isVisible]) {
            [quickLookPanel close];
        } else {
            [quickLookPanel makeKeyAndOrderFront:self];
            [quickLookPanel makeFirstResponder:self];
        }
    } else {
        [super keyDown:theEvent];
    }
}

//flagsChanged is called every time a flag-changing key is pressed, like alt-ctrl-cmd etc
-(void)flagsChanged:(NSEvent *)theEvent
{
	//We check if Alt is pressed
	if([theEvent modifierFlags]&NSAlternateKeyMask)
	{
		NSLog(@"Alt is pressed");
		altWasPressed=YES;
	}
	else
	{
		//If not, then if it's no longer pressed, we update our value. Otherwise, it means that
		//this has nothing to do with us, so we let the system handle the flag change
		if(altWasPressed)
		{
			NSLog(@"Alt is released");
			altWasPressed=NO;
		}
		else [super flagsChanged:theEvent];
	}
}
@end
