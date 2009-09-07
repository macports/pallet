//
//  NotificationsListener.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 8/4/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacPorts/MPNotifications.h>


@interface ActivityController : NSObject {
    IBOutlet NSTextField *currentTask;
    IBOutlet NSTableView *operations;
    IBOutlet NSProgressIndicator *progress;
    BOOL busy;
}

@property BOOL busy;

- (void)subscribeToNotifications;
- (void)gotMPMSG:(NSNotification *)notification;
- (void)gotMPINFO:(NSNotification *)notification;
- (void)gotMPDEFAULT:(NSNotification *)notification;
- (void)gotMPERROR:(NSNotification *)notification;

@end
