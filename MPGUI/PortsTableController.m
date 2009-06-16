//
//  PortsListController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "PortsTableController.h"


@implementation PortsTableController

@synthesize actionLauncher;

- (id)init {
    [MPMacPorts setPKGPath:@"/Users/juanger/local/macportsbuild/branch-unprivileged/Library/Tcl"];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [actionLauncher performSelectorInBackground:@selector(loadPorts) withObject:nil];
}


@end
