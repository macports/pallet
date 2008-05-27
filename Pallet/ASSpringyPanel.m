//
//  ASSpringyPanel.m
//  Pallet
//
//  Created by Randall Hansen Wood on 19/6/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ASSpringyPanel.h"
#import "ASNSViewAdditions.h"
#import "ASNSWindowAdditions.h"

@implementation ASSpringyPanel

- (void)awakeFromNib {
    [self contentResized:[NSNotification notificationWithName:
					  NSViewFrameDidChangeNotification object:[self contentView]]];
}

- (void)setContentView:(NSView *)aView {
    [super setContentView:aView];
    [self observeSizeChanges:@selector(contentResized:)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
