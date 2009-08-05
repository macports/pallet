//
//  NotificationsListener.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 8/4/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "ActivityController.h"


@implementation ActivityController

@synthesize busy;

- (void)awakeFromNib {
    [self subscribeToNotifications];
}

- (void)subscribeToNotifications {
    //  [[NSNotificationCenter defaultCenter] addObserver:self
    //                                           selector:@selector()
    //                                               name:MPINFO object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPERROR object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPWARN object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPDEBUG object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPDEFAULT object:nil];
    // This is for MPPortProcess
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(gotMPMSG:)
                                                            name:MPMSG object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(gotMPDEFAULT:)
                                                            name:MPDEFAULT object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(gotMPINFO:)
                                                            name:MPINFO object:nil];
    // This is for MPHelperTool (privileged operations)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPMSG:)
                                                 name:MPMSG object:nil];
}

- (void)gotMPINFO:(NSNotification *)notification {
    NSString *msg = [notification object];
    // NSLog(@"GOT MPINFO NOTIFICATION: %@", msg);
    if ([msg isEqual:@"Starting up"]) {
        [self setBusy:YES];
        return;
    }
    
    if ([msg isEqual:@"Shutting down"]) {
        [self setBusy:NO];
        return;
    }
}

- (void)gotMPMSG:(NSNotification *)notification {
    NSString *msg = [notification object];
    NSLog(@"GOT MPMSG NOTIFICATION: %@", msg);
}

- (void)gotMPDEFAULT:(NSNotification *)notification {
    NSString *msg = [notification object];
    NSLog(@"GOT MPDEFAULT NOTIFICATION: %@", msg);
}

@end
