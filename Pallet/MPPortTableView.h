//
//  MPPortTableView.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 7/14/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//A variable that holds the last status of the ALT key, to use it when clicking on a button
BOOL altWasPressed;

@interface MPPortTableView : NSTableView {
    IBOutlet NSPanel *quickLookPanel;
	
}

@end
