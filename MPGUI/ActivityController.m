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
    [self setBusy:NO];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPMSG:)
                                                 name:MPMSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPDEFAULT:)
                                                 name:MPDEFAULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPINFO:)
                                                 name:MPINFO object:nil];
}

- (void)gotMPINFO:(NSNotification *)notification {
    NSString *msg = [[notification userInfo] objectForKey:MPMESSAGE];
    NSLog(@"GOT MPINFO NOTIFICATION: %@", msg);
    if ([msg isEqual:@"Starting up"]) {
        [currentTask setStringValue:[[notification userInfo] objectForKey:MPMETHOD]];
        [self setBusy:YES];
        return;
    }
    
    if ([msg isEqual:@"Shutting down"]) {
        [currentTask setStringValue:@"" ];
        [self setBusy:NO];
        return;
    }
}

- (void)gotMPMSG:(NSNotification *)notification {
    NSString *msg = [[notification userInfo] objectForKey:MPMESSAGE];
    NSLog(@"GOT MPMSG NOTIFICATION: %@", msg);
}

- (void)gotMPDEFAULT:(NSNotification *)notification {
    NSString *msg = [[notification userInfo] objectForKey:MPMESSAGE];
    NSLog(@"GOT MPDEFAULT NOTIFICATION: %@", msg);
}

@end
