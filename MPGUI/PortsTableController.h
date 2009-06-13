//
//  PortsListController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GUIMacPorts.h"


@interface PortsTableController : NSObject {
    IBOutlet NSArrayController *ports;
    GUIMacPorts *macports;
}

@property GUIMacPorts *macports;

@end
