//
//  MPActionLauncher.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionLauncher.h"

static MPActionLauncher *sharedActionLauncher = nil;

#pragma mark Implementation
@implementation MPActionLauncher

@synthesize ports, isLoading, actionTool;

+ (MPActionLauncher*) sharedInstance {
    
    if (sharedActionLauncher == nil) {
        [[self alloc] init]; // assignment not done here
    }

    return sharedActionLauncher;
}

- (id)init {
    if (sharedActionLauncher == nil) {
        ports = [NSMutableArray arrayWithCapacity:1];
        sharedActionLauncher = self;
    }
    return sharedActionLauncher;
}

- (void)loadPorts {
    [self setIsLoading:YES];
    NSDictionary *allPorts = [[MPMacPorts sharedInstance] search:MPPortsAll];
    NSDictionary *installedPorts = [[MPRegistry sharedRegistry] installed];
    
    [self willChangeValueForKey:@"ports"];
    for (id port in installedPorts) {
        [[allPorts objectForKey:port] setStateFromReceipts:[installedPorts objectForKey:port]];
    }
    ports = [allPorts allValues];
    [self didChangeValueForKey:@"ports"];
    
    [self setIsLoading:NO];
}

- (void)installPort:(MPPort *)port {
    NSError * error;
    NSArray *empty = [NSArray arrayWithObject: @""];
    [port installWithOptions:empty variants:empty error:&error];
}

- (void)uninstallPort:(MPPort *)port {
    NSError * error;
    [port uninstallWithVersion:@"" error:&error];
}

- (void)upgradePort:(MPPort *)port {
    NSError * error;
    [port upgradeWithError:&error];
}

- (void)sync {
    NSError * error;
    [[MPMacPorts sharedInstance] sync:&error];
}

- (void)selfupdate {
    NSError * error;
    [[MPMacPorts sharedInstance] selfUpdate:&error];
}

- (void)cancelPortProcess {
    //  TODO: display confirmation dialog
    //        send a "Shutting down" notification
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

@end
