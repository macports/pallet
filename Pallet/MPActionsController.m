//
//  MPActionsController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionsController.h"


@implementation MPActionsController

- (IBAction)openPreferences:(id)sender {
    [NSBundle loadNibNamed:@"Preferences" owner:self];
}

- (IBAction)installWithVariants:(id)sender {
	[self install:(id) nil];
}

- (IBAction)install:(id)sender {
	NSLog(@"Staring Installation");
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(installPort:) withObject:port];
    }
	NSLog(@"Installation Completed");
}

- (IBAction)uninstall:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(uninstallPort:) withObject:port];
    }
}

- (IBAction)upgrade:(id)sender {
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(upgradePort:) withObject:port];
    }
}

- (IBAction)sync:(id)sender {
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(sync) withObject:nil];
}

- (IBAction)selfupdate:(id)sender {
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(selfupdate) withObject:nil];
}

- (IBAction)cancel:(id)sender {
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    BOOL enable = ![activityController busy];
    if ([[toolbarItem itemIdentifier] isEqual:[cancel itemIdentifier]]) {
        // Cancel button is enabled when busy
        return !enable;
    }
    
    return enable;
}

#pragma mark App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [tableController hidePredicateEditor:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pkgPath = [defaults objectForKey:@"PKGPath"];
    if (pkgPath == nil) {
        [self openPreferences:self];
    } else {
        [MPMacPorts setPKGPath:pkgPath];
        [[MPActionLauncher sharedInstance]
                    performSelectorInBackground:@selector(loadPorts) withObject:nil];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // I should check if it is running also 
    if (![[NSFileManager defaultManager] isWritableFileAtPath:[MPMacPorts PKGPath]]) {
        [[MPActionLauncher sharedInstance] cancelPortProcess];
    }
}

-(void) startQueue:(id) sender
{
	NSLog(@"Starting Queue Operations");
}

@end
