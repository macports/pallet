//
//  NotificationsListener.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 8/4/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "ActivityController.h"

BOOL errorReceived;

@implementation ActivityController

@synthesize busy;

- (void)awakeFromNib {
    [progress setUsesThreadedAnimation:YES];
    [self setBusy:NO];
    [self subscribeToNotifications];
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPMSG:)
                                                 name:MPMSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPDEFAULT:)
                                                 name:MPDEFAULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotMPINFO:)
                                                 name:MPINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
    										 selector:@selector(gotMPERROR:)
    											 name:MPERROR object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPWARN object:nil];
    //	[[NSNotificationCenter defaultCenter] addObserver:self
    //											 selector:@selector()
    //												 name:MPDEBUG object:nil];
}

- (void)gotMPINFO:(NSNotification *)notification {
    NSString *msg = [[notification userInfo] objectForKey:MPMESSAGE];
    NSLog(@"GOT MPINFO NOTIFICATION: %@", msg);
    // Starting up: A port command has been started
    if ([msg isEqual:@"Starting up"]) {
        [currentTask setStringValue:[[notification userInfo] objectForKey:MPMETHOD]];
        [self setBusy:YES];
        return;
    }
    // Shutting down: The command has finished
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

- (void)gotMPERROR:(NSNotification *)notification {
    NSString *msg = [[notification userInfo] objectForKey:MPMESSAGE];
    NSLog(@"GOT ERROR NOTIFICATION: %@", msg);
    //TODO: Display an alert
	errorReceived=YES;
}

@end
