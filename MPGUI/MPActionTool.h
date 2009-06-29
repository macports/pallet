//
//  MPActionTool.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/26/09.
//  Copyright 2009 UNAM. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>


@interface MPActionTool : NSObject
{
    MPMacPorts *macports;
}

@property MPMacPorts *macports;

- (oneway void)installPort:(byref id)port;
- (oneway void)uninstallPort:(byref id)port;
- (oneway void)upgradePort:(byref id)port;
- (oneway void)sync;
- (oneway void)selfupdate;

- (NSString*)PKGPathFromDefaults;

@end
