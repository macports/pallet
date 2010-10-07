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
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_INSTALLFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_INSTALL];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
	
}

- (void)installPortWithVariants:(NSArray *) portAndVariants {
	errorReceived=NO;
    NSError * error;
    NSArray *empty = [NSArray arrayWithObject: @""];
	//Because we get the port and the variants mixed in an array, we copy the port to a local variable,
	//and the variants array to a local array
	MPPort* port = [portAndVariants objectAtIndex:0];
	NSArray *variants = [portAndVariants objectAtIndex:1];
    [port installWithOptions:empty variants:variants error:&error];
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_INSTALLFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_INSTALL];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
	
}

- (void)uninstallPort:(MPPort *)port {
	errorReceived=NO;
    NSError * error;
    [port uninstallWithVersion:@"" error:&error];
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_UNINSTALLFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_UNINSTALL];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)upgradePort:(MPPort *)port {
	errorReceived=NO;
    NSError * error;
    [port upgradeWithError:&error];
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_UPGRADEFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_UPGRADE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)sync {
	errorReceived=NO;
    NSError * error;
    [[MPMacPorts sharedInstance] sync:&error];
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_SYNCFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_SYNC];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)selfupdate {
	errorReceived=NO;
    NSError * error;
    [[MPMacPorts sharedInstance] selfUpdate:&error];
	//Check if we have received an error, send the apropriate notification, and if everything is fine
	//send a notification to the main thread that we have completed our operation, and to advance the queue
	if(errorReceived)
		[self sendGrowlNotification: GROWL_SELFUPDATEFAILED];
	else
	{
		[self sendGrowlNotification: GROWL_SELFUPDATE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)cancelPortProcess {
    //  TODO: display confirmation dialog
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

//sendGrowlNotification is the method used to send our Growl notifications, via the Growl framework. It takes one argument, which is the
//type of notification we are sending, as defined in GrowlNotifications.h It initializes the strings we will be sending to the
//Growl Framework that comprise our notification, and finaly sends the notification
-(void) sendGrowlNotification:(int)type
{
	//The notification needs a title. We initialize an array containing the titles for each type of notification
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

	growlTitles[GROWL_ALLOPS] = [NSString stringWithString: @"Operations Completed"];
	growlTitles[GROWL_ALLOPSFAILED] = [NSString stringWithString: @"Operations Failed"];

	//The notification also needs a description. We initialize an array containing the descriptions for each type of notification
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

	growlDescriptions[GROWL_ALLOPS] = [NSString stringWithString: @"All Operations Completed Succesfully"];
	growlDescriptions[GROWL_ALLOPSFAILED] = [NSString stringWithString: @"Operations Failed"];

	//And the notification also needs a name, which Growl uses to identify it. We initialize an array containing
	//these names here
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
	
	growlNotificationNames[GROWL_ALLOPS] = [NSString stringWithString: @"OperationsCompleted"];
	growlNotificationNames[GROWL_ALLOPSFAILED] = [NSString stringWithString: @"OperationsFailed"];
	
	
	/*#################	These initializations should be moved to [init], and only call the following functions 	#################*/
	
	//Before we can send our messages, we need to call setGrowlDelegate once, due to a bug with the Growl Framework
	[GrowlApplicationBridge setGrowlDelegate:(id) @""];
	//And finaly, we send our notification, by calling notifyWithTitle with the appropriate title/description/name 
	[GrowlApplicationBridge notifyWithTitle: growlTitles[type] description: growlDescriptions[type]\
						   notificationName:growlNotificationNames[type] iconData:nil priority: 0\
								   isSticky: NO clickContext:nil];
}

@end
