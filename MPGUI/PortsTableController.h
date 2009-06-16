//
//  PortsListController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPActionLauncher.h"


@interface PortsTableController : NSObject {
    IBOutlet MPActionLauncher *actionLauncher;
}

@property MPActionLauncher *actionLauncher;

@end
