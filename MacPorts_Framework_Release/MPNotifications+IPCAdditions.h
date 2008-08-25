//
//  MPNotifications+IPCAdditions.h
//  MacPorts.Framework
//
//  Created by George  Armah on 8/24/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import "MPNotifications.h"


@interface MPNotifications (IPCAdditions) 

-(void) startIPCServerThread;
-(void) prepareIPCServerThread;
-(void) stopIPCServerThread;

@end
