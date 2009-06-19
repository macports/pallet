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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self changePredicateEditorSize:0];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark PredicateEditor delegate

- (void)ruleEditorRowsDidChange:(NSNotification *)notification {
    [self changePredicateEditorSize:[predicateEditor numberOfRows]];
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
    NSArray *subpredicates = [NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"name CONTAINS %@", name]];
    NSPredicate *newPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
    [predicateEditor setObjectValue:newPredicate];
    NSLog(@"Basic Predicate: %@", [newPredicate predicateFormat]);
    [self setPredicate:newPredicate];
}

#pragma mark Private Methods

- (void)changePredicateEditorSize:(NSInteger) newRowCount {
    if (newRowCount == rowCount)
        return;
    
    NSScrollView* tableScrollView = [portsTableView enclosingScrollView];
    NSUInteger oldOutlineViewMask = [tableScrollView autoresizingMask];
    
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
    
    
    [tableScrollView setAutoresizingMask:oldOutlineViewMask];
    [predicateEditorScrollView setAutoresizingMask:oldPredicateEditorViewMask];
    
    rowCount = newRowCount;
}

@end