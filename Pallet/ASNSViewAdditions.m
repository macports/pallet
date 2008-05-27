//
//  ASNSViewAdditions.m
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ASNSViewAdditions.h"

#define max(a,b) (((a)>(b))?(a):(b))

@implementation NSView (ASNSViewAdditions)

- (void)registerObserver:(id)anObserver forSizeChanges:(SEL)callback {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if ([self postsFrameChangedNotifications]) {
		[nc addObserver:anObserver
			   selector:callback
				   name:NSViewFrameDidChangeNotification
				 object:self];
	}        
	NSArray *children = [self subviews];
	if ( children != nil) {
		int childCount = [children count];
		int i = 0;
		for (i = 0; i < childCount; i++) {
			NSView *child = (NSView *) [children objectAtIndex: i];
			[child registerObserver: anObserver forSizeChanges: callback];
		}
	}
}

- (NSSize)checkIntersections:(NSRect)aFrame {
	NSRect intersection = NSIntersectionRect([self frame], aFrame);
	NSSize delta = NSMakeSize(NSWidth([self frame]) - NSWidth(intersection),
							  NSHeight([self frame]) - NSHeight(intersection));
	NSArray *children = [self subviews];
	if ( children != nil) {
		int childCount = [children count];
		int i=0;
		for (i=0; i < childCount; i++) {
			NSSize childDelta = [[children objectAtIndex: i] checkIntersections: aFrame];
			delta = NSMakeSize(max(delta.width, childDelta.width), max(delta.height, childDelta.height));            
		}
	}
	return delta;
}

@end