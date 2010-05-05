//
//  PreferencesController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 7/6/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>
#import "MPActionLauncher.h"


@interface PreferencesController : NSObject {
    IBOutlet NSTextField *pkgPathField;
    IBOutlet NSWindow *preferencesWindow;
}
- (IBAction)selectPKGPath:(id)sender;

@end
