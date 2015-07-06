//
//  PortsListController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "PortsTableController.h"

#pragma mark Private Methods
@interface PortsTableController (Private)

- (void)changePredicateEditorSize:(NSInteger) newRowCount;

@end

#pragma mark Implementation
@implementation PortsTableController

@synthesize predicate;

- (id)init {
    // This is the number of rows shown in the xib file
    rowCount = 1;
    return self;
}

#pragma mark PredicateEditor delegate

- (void)ruleEditorRowsDidChange:(NSNotification *)notification {
    [self changePredicateEditorSize:[predicateEditor numberOfRows]];
    NSLog(@"rileEditorRowsDidChange");
}

#pragma mark Search

- (IBAction)advancedSearch:(id)sender {
    NSPredicate* newPredicate = [predicateEditor  objectValue];
    NSLog(@"Advanced Predicate: %@", [newPredicate predicateFormat]);    

    if([newPredicate isNotEqualTo:predicate]) {
        [self setPredicate:[NSPredicate predicateWithFormat:[newPredicate predicateFormat]]];
    }
}

- (IBAction)basicSearch:(id)sender {
    // Change internal NSPredicate and the NSPredicateEditor to match the basic query
    NSString *name = [sender stringValue];
    if([name isEqual:@""]) {
        [self setPredicate:nil];
        [predicateEditor setObjectValue:nil];
    } else {
        NSArray *subpredicates = [NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"name CONTAINS %@", name]];
        NSPredicate *newPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
        // I know what I am doing to you, so I dont want to be your delegate for now
        [predicateEditor setDelegate:nil];
        [predicateEditor setObjectValue:newPredicate];
        [self setPredicate:newPredicate];
        [self changePredicateEditorSize:[predicateEditor numberOfRows]];
        // Now I want to know what you do :)
        [predicateEditor setDelegate:self];
        NSLog(@"Basic Predicate: %@", [newPredicate predicateFormat]);
    }
}

- (IBAction)hidePredicateEditor:(id)sender {
    [self changePredicateEditorSize:0];
}

#pragma mark Private Methods

- (void)changePredicateEditorSize:(NSInteger) newRowCount {
    NSLog(@"ROWS: %ld", (long)newRowCount);
    if (newRowCount == rowCount)
        return;
    
    if (newRowCount == 0) {
        [self setPredicate:[NSPredicate predicateWithFormat:@"name LIKE '*'"]];
    }
    
    NSScrollView* tableScrollView = [portsTableView enclosingScrollView];
    
    NSScrollView* predicateEditorScrollView = [predicateEditor enclosingScrollView];
    NSUInteger oldPredicateEditorViewMask = [predicateEditorScrollView autoresizingMask];
    
    [tableScrollView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
    [predicateEditorScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    BOOL growing = (newRowCount > rowCount);
    
    CGFloat heightDifference = fabs([predicateEditor rowHeight] * (newRowCount - rowCount));
    
    NSSize sizeChange = [predicateEditor convertSize:NSMakeSize(0, heightDifference) toView:nil];
    
    NSRect windowFrame = [mainWindow frame];
    windowFrame.size.height += growing ? sizeChange.height : -sizeChange.height;
    windowFrame.origin.y -= growing ? sizeChange.height : -sizeChange.height;
    [mainWindow setFrame:windowFrame display:YES animate:YES];
    
    
    [tableScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [predicateEditorScrollView setAutoresizingMask:oldPredicateEditorViewMask];
    
    rowCount = newRowCount;
}

/****************** Drawer ******************/

//These are the functions needed for our drawer. In addition to open/close, we implemented toggle as well
- (IBAction)open:(id)sender {[drawer openOnEdge:NSMinXEdge];}

- (IBAction)close:(id)sender {[drawer close];}

- (IBAction)toggle:(id)sender {
    NSDrawerState state = [drawer state];
    if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
        [drawer close];
    } else {
        [drawer openOnEdge:NSMinXEdge];
    }
}

@end