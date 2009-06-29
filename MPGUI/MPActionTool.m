//
//  MPActionTool.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/26/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionTool.h"

@implementation MPActionTool

@synthesize macports;

- (id)init {
    macports = [MPMacPorts sharedInstanceWithPkgPath:[self PKGPathFromDefaults] portOptions:nil];
    return self;
}

- (oneway void)installPort:(byref id) port {
    NSError * error;
    NSArray *empty = [NSArray arrayWithObject: @""];
    // for some reason the following line doesn't work
    //[port installWithOptions:empty variants:empty error:&error];
    // trying to get the MPPort again (if this is the only way to get it working,
    // maybe it would be better to just pass the name of the port instead of the
    // MPPort instance):
    
    NSDictionary * searchResult = [macports search:[port name]];
	MPPort * foundPort = [searchResult objectForKey:[port name]];
    
    if (foundPort != nil) {
        [foundPort installWithOptions:empty variants:empty error:&error];
    }
}

- (oneway void)uninstallPort:(byref id) port {
    NSError * error;
    
    NSDictionary * searchResult = [macports search:[port name]];
	MPPort * foundPort = [searchResult objectForKey:[port name]];
    
    if (foundPort != nil) {
        [foundPort uninstallWithVersion:@"" error:&error];
    }
}

- (oneway void)upgradePort:(byref id) port {
    NSError * error;
    
    NSDictionary * searchResult = [macports search:[port name]];
	MPPort * foundPort = [searchResult objectForKey:[port name]];
    
    if (foundPort != nil) {
        [foundPort upgradeWithError:&error];
    }
}

- (oneway void)sync {
    NSError * error;

    [[MPMacPorts sharedInstance] sync:&error];
}

- (oneway void)selfupdate {
    NSError * error;

    [[MPMacPorts sharedInstance] selfUpdate:&error];
}

- (NSString*)PKGPathFromDefaults {
    NSString *PKGPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"PKGPath"];
    return PKGPath;
}

@end

int main(int argc, char const * argv[]) {
    NSConnection *serverConnection; 
    serverConnection = [NSConnection defaultConnection];
    MPActionTool *actionTool = [[MPActionTool alloc] init];
    
    // Vending actionTool
    [serverConnection setRootObject:actionTool]; 
    
    // Register the named connection
    if ( [serverConnection registerName:@"actionTool"] ) {
        NSLog( @"Successfully registered connection with port %@", 
              [[serverConnection receivePort] description] );
    } else {
        NSLog( @"Name used by %@", 
              [[[NSPortNameServer systemDefaultPortNameServer] portForName:@"actionTool"] description] );
    }
    
    // Wait for any message
    NSLog(@"Action tool running");
    [[NSRunLoop currentRunLoop] run];
}