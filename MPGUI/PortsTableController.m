//
//  PortsListController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "PortsTableController.h"


@implementation PortsTableController

@synthesize macports;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self performSelectorInBackground:@selector(getPorts) withObject:nil];
}

- (void) getPorts {
    macports = [GUIMacPorts new];
    [ports performSelectorInBackground:@selector(addObjects:) withObject:[macports ports]];
}

@end
