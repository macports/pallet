//
//  PortsListController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "PortsTableController.h"


@implementation PortsTableController

@synthesize predicate;

- (id)init {
    [MPMacPorts setPKGPath:@"/Users/juanger/local/macportsbuild/branch-unprivileged/Library/Tcl"];
    rowCount = 1;   
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [actionLauncher performSelectorInBackground:@selector(loadPorts) withObject:nil];
    [self changePredicateEditorSize:0];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark PredicateEditor

- (IBAction)predicateEditorChanged:(id)sender {
    NSPredicate* newPredicate = [predicateEditor  objectValue];
    //Ugly Hack. It would be better to subclass NSPredicateEditorRowTemplate
    if([newPredicate isNotEqualTo:predicate]) {
        NSString *transformedFormat = [newPredicate predicateFormat];
        
        transformedFormat = [transformedFormat stringByReplacingOccurrencesOfString:@"state == \"Any\""
                                                                         withString:@"state >= 2"];
        transformedFormat = [transformedFormat stringByReplacingOccurrencesOfString:@"state == \"Installed\""
                                                                         withString:@"(state == 2 OR state == 4)"];
        transformedFormat = [transformedFormat stringByReplacingOccurrencesOfString:@"\"Outdated\""
                                                                         withString:@"4"];
        transformedFormat = [transformedFormat stringByReplacingOccurrencesOfString:@"\"Uninstalled\""
                                                                         withString:@"5"];
        [self setPredicate:[NSPredicate predicateWithFormat:transformedFormat]];
        NSLog(@"Predicate: %@", [predicate predicateFormat]);
    }
    
    [self changePredicateEditorSize:[predicateEditor numberOfRows]];
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
