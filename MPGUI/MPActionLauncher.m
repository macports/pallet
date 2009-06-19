//
//  MPActionLauncher.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionLauncher.h"

static MPActionLauncher *sharedActionLauncher = nil;

#pragma mark Private Methods
@interface MPActionLauncher (Private)

- (void)loadPorts;
- (void)installPort:(MPPort *)port;

@end

#pragma mark Implementation
@implementation MPActionLauncher

@synthesize ports, isLoading;

+ (MPActionLauncher*) sharedInstance {
    
    if (sharedActionLauncher == nil) {
        [[self alloc] init]; // assignment not done here
    }

    return sharedActionLauncher;
}

- (id)init {
    // This is a temporary pkgPath for testing purposes
    // PKGPath should be retrieved with User Defaults
    if (sharedActionLauncher == nil) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *pkgPath = [bundlePath stringByAppendingPathComponent:@"../macports-1.8/Library/Tcl"];
        pkgPath = [pkgPath stringByStandardizingPath];
        [MPMacPorts setPKGPath:pkgPath];
        [self loadPortsInBackground];
        ports = [NSMutableArray arrayWithCapacity:6000];
        sharedActionLauncher = self;
    }
    return sharedActionLauncher;
}

- (void)loadPortsInBackground {
    [self performSelectorInBackground:@selector(loadPorts) withObject:nil];
}

- (void)installPortInBackground:(MPPort *)port {
    [self performSelectorInBackground:@selector(installPort:) withObject:port];
}

#pragma mark Private Methods implementation

- (void)loadPorts {
    [self setIsLoading:YES];
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
    [self setIsLoading:NO];
}

- (void)installPort:(MPPort *)port {
    NSError * error;
    NSArray *empty = [NSArray arrayWithObject: @""];
    [port installWithOptions:empty variants:empty error:&error];
}

@end
