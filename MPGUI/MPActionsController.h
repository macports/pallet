//
//  MPActionsController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPActionLauncher.h"


@interface MPActionsController : NSObject {
    IBOutlet NSArrayController *ports;
}

- (IBAction)install:(id)sender;
- (IBAction)uninstall:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)selfupdate:(id)sender;

@end
