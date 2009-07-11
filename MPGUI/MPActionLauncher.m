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

@end

#pragma mark Implementation
@implementation MPActionLauncher

@synthesize ports, isLoading, isBusy, actionTool;

+ (MPActionLauncher*) sharedInstance {
    
    if (sharedActionLauncher == nil) {
        [[self alloc] init]; // assignment not done here
    }

    return sharedActionLauncher;
}

- (id)init {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    if (sharedActionLauncher == nil) {
        ports = [NSMutableArray arrayWithCapacity:1];
        sharedActionLauncher = self;
    }

    // This is the path to the MPActionTool
    NSString *toolPath = [bundlePath stringByAppendingPathComponent:@"Contents/MacOS/MPActionTool"];
    // Launch the MPActionTool
    actionTool = [NSTask launchedTaskWithLaunchPath:toolPath arguments:[NSArray arrayWithObject:@""]];
    
    return sharedActionLauncher;
}

- (void)loadPortsInBackground {
    [self performSelectorInBackground:@selector(loadPorts) withObject:nil];
}

- (void)installPortInBackground:(MPPort *)port {
    id theProxy;
    theProxy = [NSConnection
                    rootProxyForConnectionWithRegisteredName:@"actionTool"
                    host:nil];
    [theProxy installPort:port];
}

- (void)uninstallPortInBackground:(MPPort *)port {
    id theProxy;
    theProxy = [NSConnection
                rootProxyForConnectionWithRegisteredName:@"actionTool"
                host:nil];
    [theProxy uninstallPort:port];
}

- (void)upgradePortInBackground:(MPPort *)port {
    id theProxy;
    theProxy = [NSConnection
                rootProxyForConnectionWithRegisteredName:@"actionTool"
                host:nil];
    [theProxy upgradePort:port];
}

- (void)syncInBackground {
    id theProxy;
    theProxy = [NSConnection
                rootProxyForConnectionWithRegisteredName:@"actionTool"
                host:nil];
    [theProxy sync];
}

- (void)selfupdateInBackground {
    id theProxy;
    theProxy = [NSConnection
                rootProxyForConnectionWithRegisteredName:@"actionTool"
                host:nil];
    [theProxy selfupdate];
}

#pragma mark Private Methods implementation

- (void)loadPorts {
    [self setIsLoading:YES];
    ports = [NSMutableArray arrayWithCapacity:6000];
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
    
    id theProxy = [NSConnection
                rootProxyForConnectionWithRegisteredName:@"actionTool"
                host:nil];
    [theProxy loadPKGPath];
    
    [self setIsLoading:NO];
}

@end
