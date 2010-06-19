//
//  MPActionsController.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/19/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPActionsController.h"


@implementation MPActionsController

- (IBAction)openPreferences:(id)sender {
    [NSBundle loadNibNamed:@"Preferences" owner:self];
}

- (IBAction)installWithVariants:(id)sender {
	[self install:(id) nil];
}

- (IBAction)install:(id)sender {
	[tableController open:nil];
	NSLog(@"Staring Installation");
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"install" portName:[port name] portObject:port];
		NSLog(@"%@",[port name]);
        //[[MPActionLauncher sharedInstance]
        //    performSelectorInBackground:@selector(installPort:) withObject:port];
    }
	NSLog(@"Installation Completed");
}

- (IBAction)uninstall:(id)sender {
	[tableController open:nil];
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
 		[self queueOperation:@"uninstall" portName:[port name] portObject:port];
		NSLog(@"%@",[port name]);
		/*
       [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(uninstallPort:) withObject:port];
		 */
    }
}

- (IBAction)upgrade:(id)sender {
 	[tableController open:nil];
   NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"upgrade" portName:[port name] portObject:port];
		NSLog(@"%@",[port name]);
		/*
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(upgradePort:) withObject:port];
		 */
    }
}

- (IBAction)sync:(id)sender {
	[tableController open:nil];
	[self queueOperation:@"sync" portName:@"sync" portObject:nil];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(sync) withObject:nil];
	 */
}

- (IBAction)selfupdate:(id)sender {
	[tableController open:nil];
	[self queueOperation:@"selfupdate" portName:@"selfupdate" portObject:nil];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(selfupdate) withObject:nil];
	 */
}

- (IBAction)cancel:(id)sender {
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    BOOL enable = ![activityController busy];
    if ([[toolbarItem itemIdentifier] isEqual:[cancel itemIdentifier]]) {
        // Cancel button is enabled when busy
        return !enable;
    }
    
    return enable;
}

#pragma mark App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [tableController hidePredicateEditor:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pkgPath = [defaults objectForKey:@"PKGPath"];
    if (pkgPath == nil) {
        [self openPreferences:self];
    } else {
        [MPMacPorts setPKGPath:pkgPath];
        [[MPActionLauncher sharedInstance]
                    performSelectorInBackground:@selector(loadPorts) withObject:nil];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // I should check if it is running also 
    if (![[NSFileManager defaultManager] isWritableFileAtPath:[MPMacPorts PKGPath]]) {
        [[MPActionLauncher sharedInstance] cancelPortProcess];
    }
}

-(void) startQueue:(id) sender
{
	//[queue selectNext:nil];
	NSLog(@"Starting Queue");
	NSUInteger index;
	index = [queueArray count]-1;
	NSLog(@"Array Size is: %u", index);
	NSUInteger i;
	[queue setSelectionIndex: 0];
	queueCounter=0;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(advanceQueue)
												 name:@"advanceQ" object:nil];
	[self advanceQueue];
	
	for(i=0; i<=index+10; i++)
	{
		/*
		//We select each object from the array
		[queue setSelectionIndex:i];
		//We sleep the process for debugging puproses
		sleep(3);
		//We take the array of selected objects
		NSArray *wtf = [queue selectedObjects];
		//We then take the dictionary
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[wtf objectAtIndex:0]];
		//And we print the operations
		NSLog(@"Port %@ Operation %@",[dict objectForKey:@"port"], [dict objectForKey:@"operation"]);
		 */
		
	}
	//[queue setSelectionIndex:index];
	//[queue selectNext:nil];
}

-(void) advanceQueue
{
	NSUInteger index=queueCounter;
	if([queueArray count]>index)
	{
		NSLog(@"Advancing Queue for %u", index);
		//index = [queue selectionIndex];
		NSLog(@"Index before: %u", index);

		//We select each object from the array
		[queue setSelectionIndex:index];
		//We sleep the process for debugging puproses
		//sleep(3);
		//We then take the dictionary
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[queueArray objectAtIndex:index]];
		//And we print the operations
		NSLog(@"Port %@ Operation %@",[dict objectForKey:@"port"], [dict objectForKey:@"operation"]);
		id port= [dict objectForKey:@"object"];
		
		if ([[dict objectForKey:@"operation"] isEqualToString:@"install"])
		{
			NSLog(@"We have installation");
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(installPort:) withObject:port];		
		}
		else if([[dict objectForKey:@"operation"] isEqualToString:@"uninstall"])
		{
			NSLog(@"We have uninstallation");
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(uninstallPort:) withObject:port];		
		}
		else if([[dict objectForKey:@"operation"] isEqualToString:@"upgrade"])
		{
			NSLog(@"We have upgrade");
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(upgradePort:) withObject:port];
		}
		else if([[dict objectForKey:@"operation"] isEqualToString:@"selfupdate"])
		{
			NSLog(@"We have selfupdate");
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(selfupdate) withObject:nil];		
		}
		else if([[dict objectForKey:@"operation"] isEqualToString:@"sync"])
		{
			NSLog(@"We have sync");
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(sync) withObject:nil];		
		}
	}
	else
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"advanceQ" object:nil];
		
		int allops=GROWL_ALLOPS;
		[[MPActionLauncher sharedInstance]
		 performSelectorInBackground:@selector(sendGrowlNotification:) withObject:(id) allops];		
		
	}

	queueCounter++;
	
}

-(void) queueOperation:(NSString*)operation portName:(NSString*)name portObject: (id) port
{
	NSLog(@"Queueing our Operation");
	//NSMutableDictionary *tempDict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"wtf", @"operation", @"le_port", @"port", nil];
	[queue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:operation, @"operation", name, @"port", port, @"object", nil]];
	//[queue addObject: tempDict];
	//[queue retain];
	
}

@end
