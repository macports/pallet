//
//  ASSpringyTextField.m
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ASSpringyTextField.h"

@implementation ASSpringyTextField

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)setStringValue:(NSString *)aString {
	[super setStringValue:aString];
	[self sizeToFit];
}

- (void)setObjectValue:(id <NSCopying>)object {
	[super setObjectValue:object];
	[self sizeToFit];
}

- (void)setFont:(NSFont *)aFont {
    [super setFont:aFont];
    [self sizeToFit];
}

- (void)sizeToFit {
    float oldHeight = NSHeight([self bounds]);
    [self setPostsFrameChangedNotifications: NO];
    [super sizeToFit];
    float heightDiff = oldHeight - NSHeight([self bounds]);
    NSPoint origin = [self frame].origin;
    [self setFrameOrigin: NSMakePoint(origin.x, origin.y + heightDiff)];
    [[self superview] setNeedsDisplay: YES]; //needed to ensure we don't get garbage when the field shrinks
	
    //this actually causes a notification to be fired
    [self setPostsFrameChangedNotifications: YES];
	
}

@end