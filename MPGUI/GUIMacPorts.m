//
//  MacPorts.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "GUIMacPorts.h"
#import "GUIPort.h"


@implementation GUIMacPorts

@synthesize ports;

- (id) init {
    [MPMacPorts setPKGPath:@"/Users/juanger/local/macportsbuild/branch-unprivileged/Library/Tcl"];
    [self loadPorts];
    return self;
}

- (void) loadPorts {
    NSMutableArray *mpports = [NSMutableArray arrayWithArray:[[MPIndex new] ports]];
    NSMutableArray *guiports = [NSMutableArray arrayWithCapacity:[mpports count]];
    
    for (id port in mpports) {
        GUIPort *guiport = [[GUIPort new] initWithMPPort:port];
        [guiports addObject:guiport];
    }
    [self setPorts:guiports];
}

@end
