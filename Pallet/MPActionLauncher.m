//
//  MPActionLauncher.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionLauncher.h"
#import "MPActionsController.h"

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
		[self sendNotification: GROWL_INSTALLFAILED];
	else
	{
		[self sendNotification: GROWL_INSTALL];
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
		[self sendNotification: GROWL_INSTALLFAILED];
	else
	{
		[self sendNotification: GROWL_INSTALL];
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
		[self sendNotification: GROWL_UNINSTALLFAILED];
	else
	{
		[self sendNotification: GROWL_UNINSTALL];
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
		[self sendNotification: GROWL_UPGRADEFAILED];
	else
	{
		[self sendNotification: GROWL_UPGRADE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)revupgrade
{
    errorReceived = NO;
    NSError * error;
    [[MPMacPorts sharedInstance] revupgrade:&error];
    if(errorReceived)
    {
        [self sendNotification:GROWL_REVUPGRADEFAILED];
    }
    else
    {
        [self sendNotification:GROWL_REVUPGRADE];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
    }
}

- (void)reclaim
{
    errorReceived = NO;
    NSError * error;
    [[MPMacPorts sharedInstance] reclaim:&error];
    if(errorReceived)
    {
        [self sendNotification:GROWL_RECLAIMFAILED];
    }
    else
    {
        [self sendNotification:GROWL_RECLAIM];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
        
    }
}

- (void)diagnose:(MPPort *)port
{
    errorReceived = NO;
    NSError * error;
    [[MPMacPorts sharedInstance] diagnose:&error];
    if(errorReceived)
    {
        [self sendNotification:GROWL_DIAGNOSEFAILED];
    }
    else
    {
        [self sendNotification:GROWL_DIAGNOSE];
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
		[self sendNotification: GROWL_SYNCFAILED];
	else
	{
		[self sendNotification: GROWL_SYNC];
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
		[self sendNotification: GROWL_SELFUPDATEFAILED];
	else
	{
		[self sendNotification: GROWL_SELFUPDATE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"advanceQ" object:nil userInfo:nil];
	}
}

- (void)cancelPortProcess {
    //  TODO: display confirmation dialog
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

//sendNotification is the method used to send our notifications, via the Notification Center. It takes one argument, which is the
//type of notification we are sending, as defined in GrowlNotifications.h It initializes the strings we will be sending to the
//Notification Center that comprise our notification, and finaly sends the notification
-(void) sendNotification:(int)type
{
	//The notification needs a title. We initialize an array containing the titles for each type of notification
	NSString *notificationTitles[GROWL_TYPES];
	notificationTitles[GROWL_INSTALL]                   = @"Installation Completed";
	notificationTitles[GROWL_UNINSTALL]                 = @"Uninstall Completed";
	notificationTitles[GROWL_UPGRADE]                   = @"Upgrade Completed";
	notificationTitles[GROWL_SYNC]                      = @"Sync Completed";
    notificationTitles[GROWL_DIAGNOSE]                  = @"Diagnose Completed";
    notificationTitles[GROWL_RECLAIM]                   = @"Reclaim Completed";
    notificationTitles[GROWL_REVUPGRADE]                = @"Rev-Upgrade Completed";
	notificationTitles[GROWL_SELFUPDATE]                = @"Selfupdate Completed";
	notificationTitles[GROWL_INSTALLFAILED]             = @"Installation Failed";
	notificationTitles[GROWL_UNINSTALLFAILED]           = @"Uninstall Failed";
	notificationTitles[GROWL_UPGRADEFAILED]             = @"Upgrade Failed";
	notificationTitles[GROWL_SYNCFAILED]                = @"Sync Failed";
    notificationTitles[GROWL_DIAGNOSEFAILED]            = @"Diagnose Failed";
    notificationTitles[GROWL_RECLAIMFAILED]             = @"Reclaim Failed";
    notificationTitles[GROWL_REVUPGRADEFAILED]          = @"Rev-Upgrade Failed";
	notificationTitles[GROWL_SELFUPDATEFAILED]          = @"Selfupdate Failed";

	notificationTitles[GROWL_ALLOPS]                    = @"Operations Completed";
	notificationTitles[GROWL_ALLOPSFAILED]              = @"Operations Failed";

	//The notification also needs a description. We initialize an array containing the descriptions for each type of notification
	NSString *notificationDescriptions[GROWL_TYPES];	
	notificationDescriptions[GROWL_INSTALL]             = @"Operation completed successfully";
	notificationDescriptions[GROWL_UNINSTALL]           = @"Operation completed successfully";
	notificationDescriptions[GROWL_UPGRADE]             = @"Operation completed successfully";
	notificationDescriptions[GROWL_SYNC]                = @"Operation completed successfully";
    notificationDescriptions[GROWL_DIAGNOSE]            = @"Operation completed successfully";
    notificationDescriptions[GROWL_RECLAIM]             = @"Operation completed successfully";
    notificationDescriptions[GROWL_REVUPGRADE]          = @"Operation completed successfully";
	notificationDescriptions[GROWL_SELFUPDATE]          = @"Operation completed successfully";
	notificationDescriptions[GROWL_INSTALLFAILED]       = @"Operation Failed";
	notificationDescriptions[GROWL_UNINSTALLFAILED]     = @"Operation Failed";
	notificationDescriptions[GROWL_UPGRADEFAILED]       = @"Operation Failed";
	notificationDescriptions[GROWL_SYNCFAILED]          = @"Operation Failed";
    notificationDescriptions[GROWL_DIAGNOSEFAILED]      = @"Operation Failed";
    notificationDescriptions[GROWL_RECLAIMFAILED]       = @"Operation Failed";
    notificationDescriptions[GROWL_REVUPGRADEFAILED]    = @"Operation Failed";
	notificationDescriptions[GROWL_SELFUPDATEFAILED]    = @"Operation Failed";

	notificationDescriptions[GROWL_ALLOPS]              = @"All Operations Completed Succesfully";
	notificationDescriptions[GROWL_ALLOPSFAILED]        = @"Operations Failed";

	
    //Call the notification center to do it's notificational duties.
    NSUserNotification *notification                    = [[NSUserNotification alloc] init];
    notification.title                                  = notificationTitles[type];
    notification.informativeText                        = notificationDescriptions[type];
    notification.soundName                              = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [notification release];
    
}

@end
