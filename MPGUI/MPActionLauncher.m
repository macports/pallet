//
//  MPActionLauncher.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionLauncher.h"


@implementation MPActionLauncher

@synthesize ports;

- (id)init {
    // This is a temporary pkgPath for testing purposes
    // PKGPath should be retrieved with User Defaults
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *pkgPath = [bundlePath stringByAppendingPathComponent:@"../macports-1.8/Library/Tcl"];
    pkgPath = [pkgPath stringByStandardizingPath];
    [MPMacPorts setPKGPath:pkgPath];
    NSLog(pkgPath);
    ports = [NSMutableArray arrayWithCapacity:6000];
    [self performSelectorInBackground:@selector(loadPorts) withObject:nil];
    return self;
}

- (void)loadPorts {
    NSDictionary *allPorts = [[MPMacPorts sharedInstance] search:MPPortsAll];
    NSDictionary *installedPorts = [[MPRegistry sharedRegistry] installed];
    
    [self willChangeValueForKey:@"ports"];    
    for (id port in allPorts) {
        MPPort *mpport = [allPorts objectForKey:port];
        [mpport setState:MPPortStateNotInstalled];
        [ports addObject:mpport];
    }
    
    for (id port in installedPorts) {
        [[allPorts objectForKey:port] setStateFromReceipts:[installedPorts objectForKey:port]];
    }
    [self didChangeValueForKey:@"ports"];
}

@end
