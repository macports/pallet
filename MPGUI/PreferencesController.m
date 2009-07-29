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
        [defaults setObject:path forKey:@"PKGPath"];
        NSLog(@"PATH: %@", path);
        [MPMacPorts setPKGPath:path];
        [[MPActionLauncher sharedInstance] 
                    performSelectorInBackground:@selector(loadPorts) withObject:nil];
    }
}

@end
