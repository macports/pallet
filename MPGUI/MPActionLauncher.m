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
- (void)uninstallPort:(MPPort *)port;
- (void)sync;
- (void)selfupdate;

@end

#pragma mark Implementation
@implementation MPActionLauncher

@synthesize ports, isLoading, isBusy;

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

- (void)uninstallPortInBackground:(MPPort *)port {
    [self performSelectorInBackground:@selector(uninstallPort:) withObject:port];
}

- (void)syncInBackground {
    [self performSelectorInBackground:@selector(sync) withObject:nil];
}

- (void)selfupdateInBackground {
    [self performSelectorInBackground:@selector(selfupdate) withObject:nil];
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
    [self setIsBusy:YES];
    [port installWithOptions:empty variants:empty error:&error];
    [port setState:MPPortStateLearnState];
    [self setIsBusy:NO];
}

- (void)uninstallPort:(MPPort *)port {
    NSError * error;
    [self setIsBusy:YES];
    [port uninstallWithVersion:nil error:&error];
    [port setState:MPPortStateLearnState];
    [self setIsBusy:NO];
}

- (void)sync {
    NSError * error;
    [self setIsBusy:YES];
    [[MPMacPorts sharedInstance] sync:&error];
    [self setIsBusy:NO];
}

- (void)selfupdate {
    NSError * error;
    [self setIsBusy:YES];
    [[MPMacPorts sharedInstance] selfUpdate:&error];
    [self setIsBusy:NO];
}


@end
