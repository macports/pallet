//
//  GUIPort.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>


@interface GUIPort : NSObject {
    MPPort *port;
    NSImage *state;
}

@property (copy) NSImage *state;

- (id) initWithMPPort:(MPPort*)mpport;

//- (void) install;
//- (void) uninstall;


@end
