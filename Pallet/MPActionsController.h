//
//  MPActionsController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPActionLauncher.h"
#import "PortsTableController.h"
#import "ActivityController.h"


@interface MPActionsController : NSObject {
    IBOutlet NSArrayController *ports;
    IBOutlet PortsTableController *tableController;
    IBOutlet ActivityController *activityController;
    
    IBOutlet NSToolbarItem *cancel;
	IBOutlet NSButton *startQueueButton;
    IBOutlet NSArrayController *queue;
    IBOutlet PortsTableController *queueController;
}

- (IBAction)openPreferences:(id)sender;
- (IBAction)install:(id)sender;
- (IBAction)installWithVariants:(id)sender;
- (IBAction)uninstall:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)selfupdate:(id)sender;
- (IBAction)cancel:(id)sender;

- (void) queueOperation: (NSString*) operation andPort: (NSString*) port;

-(IBAction) startQueue:(id) sender;

@end
