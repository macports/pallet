//
//  Notification+ThreadAdditions.h
//  MacPorts.Framework
//
//  Created by George  Armah on 9/1/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Using code from CococaDev to post Notifications to main thread
// http://www.cocoadev.com/index.pl?NotificationsAcrossThreads

@interface NSNotificationCenter (NSNotificationCenterAdditions)
- (void) postNotificationOnMainThread:(NSNotification *) notification;
- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait;

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object;
- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo;
- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait;
@end

@interface NSNotificationQueue (NSNotificationQueueAdditions)
- (void) enqueueNotificationOnMainThread:(NSNotification *) notification postingStyle:(NSPostingStyle) postingStyle;
- (void) enqueueNotificationOnMainThread:(NSNotification *) notification postingStyle:(NSPostingStyle) postingStyle coalesceMask:(unsigned) coalesceMask forModes:(NSArray *) modes;
@end