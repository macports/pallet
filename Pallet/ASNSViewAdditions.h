//
//  ASNSViewAdditions.h
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSView (ASNSViewAdditions)

- (void)registerObserver:(id)anObserver forSizeChanges:(SEL)callback;
- (NSSize)checkIntersections:(NSRect)aFrame;

@end
