//
//  PortsListController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PortsTableController : NSObject {
    IBOutlet NSTableView *portsTableView;
    IBOutlet NSPredicateEditor *predicateEditor;
    IBOutlet NSWindow *mainWindow;

    // NSPredicateEditor management
    NSPredicate *predicate;
    NSInteger rowCount;
}

@property (copy) NSPredicate *predicate;

- (IBAction)advancedSearch:(id)sender;
- (IBAction)basicSearch:(id)sender;

@end

