//
//  ASNSWindowAdditions.h
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindow (ASNSWindowAdditions)

- (void)observeSizeChanges:(SEL)callback;
- (void)setFrameSizeMaintaingOrigin:(NSSize)newFrameSize;
- (void)contentResized:(NSNotification *)notification;

@end
