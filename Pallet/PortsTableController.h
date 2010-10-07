//
//  PortsListController.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

/*!
 @header PortsTableController
 This is the controller responsible of managing search operations in the
 ports table. This uses a NSPredicateEditor to implement the advanced search
 and a NSPredicate to filter the NSArrayController which contains all the 
 available ports.
*/


#import <Cocoa/Cocoa.h>
#import "MPActionLauncher.h"

//Importing doesnt work. Therefore, we include NSDrawer.h 
#include <AppKit/NSDrawer.h>

/*!
 @class PortsTableController
 @abstract Wrapper for MacPorts Framework actions
 @discussion Contains a shared per thread MacPorts Framework wrapper
 */
@interface PortsTableController : NSObject  {
    IBOutlet NSTableView *portsTableView;
    IBOutlet NSPredicateEditor *predicateEditor;
    IBOutlet NSWindow *mainWindow;
	IBOutlet NSDrawer *drawer;
	IBOutlet NSTableView *drawerTable;

    // NSPredicateEditor management
    NSPredicate *predicate;
    NSInteger rowCount;
}

/*! 
 @var predicate
 @abstract The NSPredicate which filters the ports table
*/
@property (copy) NSPredicate *predicate;

/*!
 @brief Creates a NSPredicate based in the rows of the NSPredicateEditor
 @param sender The object that sends the action
*/
- (IBAction)advancedSearch:(id)sender;

/*!
 @brief Creates a NSPredicate based in the search text field
 @param sender The object that sends the action
*/
- (IBAction)basicSearch:(id)sender;


- (IBAction)hidePredicateEditor:(id)sender;


//Drawer methods
- (IBAction)open:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)toggle:(id)sender;


@end

