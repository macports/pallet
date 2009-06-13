//
//  MacPorts.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>

@interface GUIMacPorts : NSObject {
	NSMutableArray *ports;
}

@property (copy) NSMutableArray *ports;

- (void) loadPorts;
//- (void) selfupdate;
//- (void) sync;

@end
