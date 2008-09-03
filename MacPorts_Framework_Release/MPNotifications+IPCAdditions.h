//
//  MPNotifications+IPCAdditions.h
//  MacPorts.Framework
//
//  Created by George  Armah on 8/24/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import "MPNotifications.h"

static int clientHasQuit = 0;
static int hasInstalledSignalsToSocket = 0;

@interface MPNotifications (IPCAdditions) 
-(BOOL) terminateBackgroundThread;
-(void) setTerminateBackgroundThread:(BOOL)newStatus;
-(void) startIPCServerThread:(NSDictionary *)serverInfo;
-(void) prepareIPCServerThread;
-(void) stopIPCServerThread;
-(void) sendIPCNotification:(NSString *)message;
@end
