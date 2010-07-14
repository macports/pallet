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
			//[variantsPanel close];
        } else {
            [quickLookPanel makeKeyAndOrderFront:self];
            [quickLookPanel makeFirstResponder:self];
        }
    } else {
        [super keyDown:theEvent];
    }
}


-(void)flagsChanged:(NSEvent *)theEvent
{
	if([theEvent modifierFlags]&NSAlternateKeyMask)
	{
		NSLog(@"Alt is pressed");
		altWasPressed=YES;
	}
	else
	{
		if(altWasPressed)
		{
			NSLog(@"Alt is released");
			altWasPressed=NO;
		}
		else [super flagsChanged:theEvent];
	}
}
@end
