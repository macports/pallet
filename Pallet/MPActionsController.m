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

- (IBAction)installWithVariantsPerform:(id)sender {
	if (altWasPressed)
	{
		[self clearQueue];
	}
	[variantsPanel close];

	[tableController open:nil];
	NSLog(@"Staring Installation");
    NSArray *selectedPorts = [ports selectedObjects];
	id port = [selectedPorts objectAtIndex:0];		
	//NSLog(@"Lets see %@", [checkboxes[0] title]);
	//NSLog(@"Port variants:");
	NSMutableString *variantsString = [NSMutableString stringWithCapacity:50];
	[variantsString appendString:[port name]];
	NSMutableArray *variants=[NSMutableArray arrayWithCapacity:10];
	for(UInt i=0; i<[[port valueForKey:@"variants"] count];i++)
	{
		//NSLog(@"%@",[[port valueForKey:@"variants"] objectAtIndex:i]);
		if ([checkboxes[i] state] == NSOnState)
		{
			[variants addObject: [[port valueForKey:@"variants"] objectAtIndex:i]];
			[variants addObject: [NSString stringWithString:@"+"]];
			[variantsString appendString:@"+"];
			[variantsString appendString:[[port valueForKey:@"variants"] objectAtIndex:i]];			
		}
	}
	//NSLog(@"End of Variants");
		
	/*
	for(UInt i=0; i<[variants count]; i++)
	{
		NSLog(@"variants array at #%i: %@", i, [variants objectAtIndex:i]);
	}
	 */
	
	[self queueOperation:@"install+" portName:variantsString portObject:port variants: variants];
	NSLog(@"%@",[port name]);

	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)installWithVariantsChoose:(id)sender 
{
	NSArray *selectedPorts = [ports selectedObjects];
	id port = [selectedPorts objectAtIndex:0];
	
	if([[port valueForKey:@"variants"] count] > 0)
	{
		//id checkboxes[10];
		checkboxes[0]=chckbx0;
		checkboxes[1]=chckbx1;
		checkboxes[2]=chckbx2;
		checkboxes[3]=chckbx3;
		checkboxes[4]=chckbx4;
		checkboxes[5]=chckbx5;
		checkboxes[6]=chckbx6;
		checkboxes[7]=chckbx7;
		checkboxes[8]=chckbx8;
		checkboxes[9]=chckbx9;
		
		for(UInt i=0; i< 10;i++)
		{
			[checkboxes[i] setAlphaValue:0];
		}
		//[chckbx1 setAlphaValue:0];
		//NSLog(@"Variants count: %i", [[port valueForKey:@"variants"] count]);
		//NSLog(@"Port variants:");
		for(UInt i=0; i<[[port valueForKey:@"variants"] count];i++)
		{
			//NSLog(@"%@",[[port valueForKey:@"variants"] objectAtIndex:i]);
			[checkboxes[i] setAlphaValue:1];
			[checkboxes[i] setState:NSOffState];
			NSAttributedString *tempString = [[NSAttributedString alloc]\
											  initWithString:[[port valueForKey:@"variants"] objectAtIndex:i]\
		attributes: [NSDictionary dictionaryWithObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName]];
			[checkboxes[i] setAttributedTitle:tempString];
			 
		}
		//NSLog(@"End of Variants");
		
		
		[variantsPanel makeKeyAndOrderFront:self];
		//[chckbx2 setTitle:@"hehe"];
		//[variantsPanel makeFirstResponder:[tableController mainWindow]];
	}
	else
	{
		[self install:nil];
	}

}

- (IBAction)install:(id)sender {
	if (altWasPressed)
	{
		[self clearQueue];
	}	 
	[tableController open:nil];
	NSLog(@"Staring Installation");
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"install" portName:[port name] portObject:port variants:0];
		NSLog(@"%@",[port name]);
        //[[MPActionLauncher sharedInstance]
        //    performSelectorInBackground:@selector(installPort:) withObject:port];
    }
	//NSLog(@"Installation Completed");
	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)uninstall:(id)sender {
	
	if (altWasPressed)
	{
		[self clearQueue];
	}	 
	[tableController open:nil];
    NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
 		[self queueOperation:@"uninstall" portName:[port name] portObject:port variants:0];
		NSLog(@"%@",[port name]);
		/*
       [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(uninstallPort:) withObject:port];
		 */
    }
	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)upgrade:(id)sender {
	if (altWasPressed)
	{
		[self clearQueue];
	}	 
 	[tableController open:nil];
   NSArray *selectedPorts = [ports selectedObjects];
    for (id port in selectedPorts) {
		[self queueOperation:@"upgrade" portName:[port name] portObject:port variants:0];
		NSLog(@"%@",[port name]);
		/*
        [[MPActionLauncher sharedInstance]
            performSelectorInBackground:@selector(upgradePort:) withObject:port];
		 */
    }
	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)sync:(id)sender {
	if (altWasPressed)
	{
		[self clearQueue];
	}	 
	[tableController open:nil];
	[self queueOperation:@"sync" portName:@"-" portObject:@"-" variants:0];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(sync) withObject:nil];
	 */
	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)selfupdate:(id)sender {
	if (altWasPressed)
	{
		[self clearQueue];
	}	 
	[tableController open:nil];
	[self queueOperation:@"selfupdate" portName:@"-" portObject:@"-" variants:0];
	/*
    [[MPActionLauncher sharedInstance]
        performSelectorInBackground:@selector(selfupdate) withObject:nil];
	 */
	if (altWasPressed)
		[self startQueue:nil];
}

- (IBAction)cancel:(id)sender {
    [[MPMacPorts sharedInstance] cancelCurrentCommand];
}

- (IBAction) toggleInfoPanel: (id) sender;
{
	if ([infoPanel isVisible]) {
		[infoPanel close];
		//[variantsPanel close];
	} else {
		[infoPanel makeKeyAndOrderFront:self];
		//May need to make our MPTableView as the first responder
		//[infoPanel makeFirstResponder:self];
	}
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
		else if([[dict objectForKey:@"operation"] isEqualToString:@"install+"])
		{
			NSLog(@"We have installation with variants");
			NSArray *variants = [dict objectForKey:@"variants"];
			NSArray *portAndVariants = [NSArray arrayWithObjects:port, variants, nil];
			[[MPActionLauncher sharedInstance]
			 performSelectorInBackground:@selector(installPortWithVariants:) withObject:portAndVariants];		
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

-(void) queueOperation:(NSString*)operation portName:(NSString*)name portObject: (id) port variants: (NSMutableArray*) variants
{
	NSImage *image;
	if ([operation isEqualToString:@"install"])
	{
		image = [NSImage imageNamed:@"TB_Install.icns"];
	}
	else if ([operation isEqualToString:@"install+"])
	{
		image = [NSImage imageNamed:@"TB_InstallWithVar.icns"];
	}
	else if ([operation isEqualToString:@"uninstall"])
	{
		image = [NSImage imageNamed:@"TB_Uninstall.icns"];
	}
	else if ([operation isEqualToString:@"upgrade"])
	{
		image = [NSImage imageNamed:@"TB_Upgrade.icns"];
	}
	else if ([operation isEqualToString:@"sync"])
	{
		image = [NSImage imageNamed:@"TB_Sync.icns"];
	}
	else if ([operation isEqualToString:@"selfupdate"])
	{
		image = [NSImage imageNamed:@"TB_Selfupdate.icns"];
	}
	
	
	if(variants!=nil)
	{
		NSLog(@"yay");
		for(UInt i=0; i<[variants count]; i++)
		{
			NSLog(@"variants array at #%i: %@", i, [variants objectAtIndex:i]);
		}
	}
	
	NSLog(@"Queueing our Operation");
	[queue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:operation, @"operation", name, @"port", port, @"object", image, @"image", variants, @"variants", nil]];
	//[queue addObject: tempDict];
	//[queue retain];
}

/*
-(void) removeFromQueue:(id)sender
{
	UInt index = [queue selectionIndex];
	[queue removeObject: [[queue selectedObjects] objectAtIndex:0]];
	[queue setSelectionIndex: index];
}
*/

-(void) clearQueue
{
	//NSLog(@"We have the alt key pressed");
	NSIndexSet *tempIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [queueArray count])];
	[queue removeObjectsAtArrangedObjectIndexes:tempIndex];
	
}

-(id) init
{
	[variantsPanel setFloatingPanel:YES];
	
	[super init];
    return self;
}

@end
