//
//  MPActionsController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionsController.h"


@implementation MPActionsController

- (IBAction)install:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance] installPortInBackground:port];
    }
}

- (IBAction)uninstall:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance] uninstallPortInBackground:port];
    }
}

@end
