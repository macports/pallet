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

- (IBAction)upgrade:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance] upgradePortInBackground:port];
    }
}

- (IBAction)sync:(id)sender {
    [[MPActionLauncher sharedInstance] syncInBackground];
}

- (IBAction)selfupdate:(id)sender {
    [[MPActionLauncher sharedInstance] selfupdateInBackground];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    BOOL enable = ![[MPActionLauncher sharedInstance] isBusy];
    return enable;
}

#pragma mark App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[MPActionLauncher sharedInstance] loadPortsInBackground];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[[MPActionLauncher sharedInstance] actionTool] terminate];
}

@end
