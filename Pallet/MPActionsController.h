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
#import "MPCheckbox.h"

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
	
	MPCheckbox* checkboxes[10];
	
	IBOutlet MPCheckbox *chckbx0;
	IBOutlet MPCheckbox *chckbx1;
	IBOutlet MPCheckbox *chckbx2;
	IBOutlet MPCheckbox *chckbx3;
	IBOutlet MPCheckbox *chckbx4;
	IBOutlet MPCheckbox *chckbx5;
	IBOutlet MPCheckbox *chckbx6;
	IBOutlet MPCheckbox *chckbx7;
	IBOutlet MPCheckbox *chckbx8;
	IBOutlet MPCheckbox *chckbx9;	
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
- (IBAction)toggleInfoPanel: (id) sender;

-(IBAction)clickCheckbox:(id)sender;
-(void)checkConflicts: (NSString*) portName;

- (void)queueOperation: (NSString*) operation portName: (NSString*) name portObject: (id) port variants: (NSMutableArray*) variants;

-(IBAction) startQueue:(id) sender;
//-(IBAction) removeFromQueue:(id) sender;
-(void)clearQueue;
-(void)advanceQueue;

@end
