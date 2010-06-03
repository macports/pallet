//
//  MPActionLauncher.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionLauncher.h"

extern BOOL errorReceived;

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
	errorReceived=NO;
    NSError * error;
    NSArray *empty = [NSArray arrayWithObject: @""];
    [port installWithOptions:empty variants:empty error:&error];
	if(errorReceived)
		[self sendGrowlNotification: GROWL_INSTALLFAILED];
	else
		[self sendGrowlNotification: GROWL_INSTALL];
}

- (void)uninstallPort:(MPPort *)port {
	errorReceived=NO;
    NSError * error;
    [port uninstallWithVersion:@"" error:&error];
	if(errorReceived)
		[self sendGrowlNotification: GROWL_UNINSTALLFAILED];
	else
		[self sendGrowlNotification: GROWL_UNINSTALL];
}

- (void)upgradePort:(MPPort *)port {
	errorReceived=NO;
    NSError * error;
    [port upgradeWithError:&error];
	if(errorReceived)
		[self sendGrowlNotification: GROWL_UPGRADEFAILED];
	else
		[self sendGrowlNotification: GROWL_UPGRADE];
}

- (void)sync {
	errorReceived=NO;
    NSError * error;
    [[MPMacPorts sharedInstance] sync:&error];
	if(errorReceived)
		[self sendGrowlNotification: GROWL_SYNCFAILED];
	else
		[self sendGrowlNotification: GROWL_SYNC];
}

- (void)selfupdate {
	errorReceived=NO;
    NSError * error;
    [[MPMacPorts sharedInstance] selfUpdate:&error];
	//NSLog(@"yay");
	//NSInteger code = [error code];
	//NSLog(@"Selfupdate Error Code %i", code);
	if(errorReceived)
		[self sendGrowlNotification: GROWL_SELFUPDATEFAILED];
	else
		[self sendGrowlNotification: GROWL_SELFUPDATE];
}

- (void)cancelPortProcess {
    //  TODO: display confirmation dialog
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

-(void) sendGrowlNotification:(int)type
{
	NSString *growlTitles[GROWL_TYPES];
	growlTitles[GROWL_INSTALL] = [NSString stringWithString: @"Installation Completed"];
	growlTitles[GROWL_UNINSTALL] = [NSString stringWithString: @"Uninstall Completed"];
	growlTitles[GROWL_UPGRADE] = [NSString stringWithString: @"Upgrade Completed"];
	growlTitles[GROWL_SYNC] = [NSString stringWithString: @"Sync Completed"];
	growlTitles[GROWL_SELFUPDATE] = [NSString stringWithString: @"Selfupdate Completed"];
	growlTitles[GROWL_INSTALLFAILED] = [NSString stringWithString: @"Installation Failed"];
	growlTitles[GROWL_UNINSTALLFAILED] = [NSString stringWithString: @"Uninstall Failed"];
	growlTitles[GROWL_UPGRADEFAILED] = [NSString stringWithString: @"Upgrade Failed"];
	growlTitles[GROWL_SYNCFAILED] = [NSString stringWithString: @"Sync Failed"];
	growlTitles[GROWL_SELFUPDATEFAILED] = [NSString stringWithString: @"Selfupdate Failed"];
	
	NSString *growlDescriptions[GROWL_TYPES];
	
	growlDescriptions[GROWL_INSTALL] = [NSString stringWithString: @"Operation completed successfully"];
	growlDescriptions[GROWL_UNINSTALL] = [NSString stringWithString: @"Operation completed successfully"];
	growlDescriptions[GROWL_UPGRADE] = [NSString stringWithString: @"Operation completed successfully"];
	growlDescriptions[GROWL_SYNC] = [NSString stringWithString: @"Operation completed successfully"];
	growlDescriptions[GROWL_SELFUPDATE] = [NSString stringWithString: @"Operation completed successfully"];
	growlDescriptions[GROWL_INSTALLFAILED] = [NSString stringWithString: @"Operation Failed"];
	growlDescriptions[GROWL_UNINSTALLFAILED] = [NSString stringWithString: @"Operation Failed"];
	growlDescriptions[GROWL_UPGRADEFAILED] = [NSString stringWithString: @"Operation Failed"];
	growlDescriptions[GROWL_SYNCFAILED] = [NSString stringWithString: @"Operation Failed"];
	growlDescriptions[GROWL_SELFUPDATEFAILED] = [NSString stringWithString: @"Operation Failed"];
	
	NSString *growlNotificationNames[GROWL_TYPES];
	
	growlNotificationNames[GROWL_INSTALL] = [NSString stringWithString: @"InstallCompleted"];
	growlNotificationNames[GROWL_UNINSTALL] = [NSString stringWithString: @"UninstallCompleted"];
	growlNotificationNames[GROWL_UPGRADE] = [NSString stringWithString: @"UpgradeCompleted"];
	growlNotificationNames[GROWL_SYNC] = [NSString stringWithString: @"SyncCompleted"];
	growlNotificationNames[GROWL_SELFUPDATE] = [NSString stringWithString: @"SelfupdateCompleted"];
	growlNotificationNames[GROWL_INSTALLFAILED] = [NSString stringWithString: @"InstallFailed"];
	growlNotificationNames[GROWL_UNINSTALLFAILED] = [NSString stringWithString: @"UninstallFailed"];
	growlNotificationNames[GROWL_UPGRADEFAILED] = [NSString stringWithString: @"UpgradeFailed"];
	growlNotificationNames[GROWL_SYNCFAILED] = [NSString stringWithString: @"SyncFailed"];
	growlNotificationNames[GROWL_SELFUPDATEFAILED] = [NSString stringWithString: @"SelfupdateFailed"];
	
	[GrowlApplicationBridge setGrowlDelegate:(id) @""];
	[GrowlApplicationBridge notifyWithTitle: growlTitles[type] description: growlDescriptions[type]\
						   notificationName:growlNotificationNames[type] iconData:nil priority: 0\
								   isSticky: NO clickContext:nil];
}

@end
