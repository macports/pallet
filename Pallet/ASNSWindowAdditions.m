//
//  ASNSWindowAdditions.m
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ASNSWindowAdditions.h"
#import "ASNSViewAdditions.h"

@interface NSWindow (ASNSWindowAdditionsPrivateMethods)
- (void) sizeToFit;
@end

@implementation NSWindow (ASNSWindowAdditions)

- (void)observeSizeChanges:(SEL)callback {
	NSView *view = [self contentView];    
	if (view == nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	} else {
		[view registerObserver:self forSizeChanges:callback];
	}
}

- (void)contentResized:(NSNotification *)notification {
	if ([self contentView] != nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[self sizeToFit];
		[self observeSizeChanges:@selector(contentResized:)];
	}
}

- (void)sizeToFit {
	NSSize size = [self minSize];
	NSSize maxSize = [self maxSize];
	NSSize delta = NSMakeSize(-1, -1);
	while (size.width <= maxSize.width && size.height <= maxSize.height && !NSEqualSizes(delta, NSZeroSize)) {
		[self setFrameSizeMaintaingOrigin:size];
		delta = [[self contentView] checkIntersections:[[self contentView] bounds]];
		size.width += delta.width;
		size.height += delta.height;
	}
}

- (void)setFrameSizeMaintaingOrigin:(NSSize)newFrameSize {
	NSPoint origin = [self frame].origin;
	float originalHeight = NSHeight([self frame]);
	origin.y += (originalHeight - newFrameSize.height);
	[self setFrame:NSMakeRect(origin.x, origin.y, newFrameSize.width, newFrameSize.height) display:YES animate:YES];
}

@end
