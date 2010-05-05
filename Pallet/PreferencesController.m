//
//  PreferencesController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 7/6/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

- (IBAction)selectPKGPath:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger result = [openPanel runModalForDirectory:[defaults objectForKey:@"NSNavLastCurrentDirectory"] file:nil types:nil];
    if(result == NSOKButton) {
        NSString *path = [[openPanel filenames] objectAtIndex:0];
        // Validate Directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existsAsDirectory;
        NSString *macportsDir = [path stringByAppendingPathComponent:@"macports1.0"];
        NSString *macportsFile = [macportsDir stringByAppendingPathComponent:@"macports.tcl"];
        BOOL containsMacPortsTcl;
        [fileManager fileExistsAtPath:macportsDir isDirectory:&existsAsDirectory];
        containsMacPortsTcl = [fileManager fileExistsAtPath:macportsFile isDirectory:nil];
        if(existsAsDirectory && containsMacPortsTcl) {
            [defaults setObject:path forKey:@"PKGPath"];
            [MPMacPorts setPKGPath:path];
            [[MPActionLauncher sharedInstance] 
             performSelectorInBackground:@selector(loadPorts) withObject:nil];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"You selected an invalid directory" 
                                    defaultButton:@"OK" 
                                    alternateButton:nil 
                                    otherButton:nil 
                                    informativeTextWithFormat:@"You have to use the directory where macports1.0 was installed by MacPorts.\n\nGenerally it should be /Library/Tcl"];
            [alert runModal];
        }
    }
}

@end
