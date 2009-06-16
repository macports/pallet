//
//  MPActionLauncher.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>

@interface MPActionLauncher : NSObject {
    NSMutableArray *ports;
}

@property (copy) NSMutableArray *ports;

- (void) loadPorts;


@end
