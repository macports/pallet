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

#import "GrowlNotifications.h"

extern BOOL altWasPressed;

@interface MPActionsController : NSObject {
    IBOutlet NSArrayController *ports;
    IBOutlet PortsTableController *tableController;
    IBOutlet ActivityController *activityController;
    
    IBOutlet NSToolbarItem *cancel;
	IBOutlet NSButton *startQueueButton;
	IBOutlet NSButton *removeFromQueueButton;
	IBOutlet NSMutableArray *queueArray;
    IBOutlet NSArrayController *queue;
	NSUInteger queueCounter;
	
	//Variants Panel
    IBOutlet NSPanel *variantsPanel;
	
	//Info Panel
	IBOutlet NSPanel *infoPanel;
	
	id checkboxes[10];
	
	IBOutlet NSButton *chckbx0;
	IBOutlet NSButton *chckbx1;
	IBOutlet NSButton *chckbx2;
	IBOutlet NSButton *chckbx3;
	IBOutlet NSButton *chckbx4;
	IBOutlet NSButton *chckbx5;
	IBOutlet NSButton *chckbx6;
	IBOutlet NSButton *chckbx7;
	IBOutlet NSButton *chckbx8;
	IBOutlet NSButton *chckbx9;	
}

- (IBAction)openPreferences:(id)sender;
- (IBAction)install:(id)sender;
- (IBAction)installWithVariantsChoose:(id)sender;
- (IBAction)installWithVariantsPerform:(id)sender;
- (IBAction)uninstall:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)selfupdate:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction) toggleInfoPanel: (id) sender;

- (void) queueOperation: (NSString*) operation portName: (NSString*) name portObject: (id) port variants: (NSMutableArray*) variants;

-(IBAction) startQueue:(id) sender;
//-(IBAction) removeFromQueue:(id) sender;
-(void) clearQueue;
-(void) advanceQueue;

@end
