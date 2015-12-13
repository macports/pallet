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

//After choosing the variants, this method is called when the user clicks on the Go button
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
		
		//If the checkbox is checked, the variant is added on the list. If it is a default_variant, a '+' is added in the name,
		//to comply with the mportopen arguments
		if ([checkboxes[i] state] == NSOnState)
		{
			if (![checkboxes[i] isDefault])
			{
				[variants addObject: [[port valueForKey:@"variants"] objectAtIndex:i]];
				[variants addObject: @"+"];
			}

			[variantsString appendString:@"+"];
			[variantsString appendString:[[port valueForKey:@"variants"] objectAtIndex:i]];			
		}
		else if([checkboxes[i] isDefault])
		{
			//If the checkbox is unchecked, we need to check if it is a default_variant, and if so, add it in the list with '-'
			//in the name, to let macports know that we wish to not use it
			[variants addObject: [[port valueForKey:@"variants"] objectAtIndex:i]];
			[variants addObject: @"-"];
			[variantsString appendString:@"-"];
			[variantsString appendString:[[port valueForKey:@"variants"] objectAtIndex:i]];			
		}

	}
	//NSLog(@"End of Variants");
	
	[self queueOperation:@"install+" portName:variantsString portObject:port variants: variants];
	NSLog(@"%@",[port name]);

	if (altWasPressed)
		[self startQueue:nil];
}

//This method is called when the user clicks install with variants
- (IBAction)installWithVariantsChoose:(id)sender 
{
	NSArray *selectedPorts = [ports selectedObjects];
	id port = [selectedPorts objectAtIndex:0];
	
	//Only go through the fuss if there are variants, otherwise, perform a normal install
	if([[port valueForKey:@"variants"] count] > 0)
	{
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
		
		//Hide all checkboxes first
		for(UInt i=0; i< 10;i++)
		{
			[checkboxes[i] setAlphaValue:0];
		}
		//NSLog(@"Port variants:");
		//Call checkDefaults to compute the NSMutableArray for key default_variants
		[port checkDefaults];		
		NSMutableArray *defaultVariants= [port objectForKey:@"default_variants"];
		
		NSLog(@"Default variants count: %lu", (unsigned long)[defaultVariants count]);
		for(UInt i=0; i<[[port valueForKey:@"variants"] count];i++)
		{
			//If the variant is included in the default_variants, then check it. Otherwise leave it unchecked
			//NSLog(@"%@",[[port valueForKey:@"variants"] objectAtIndex:i]);
			if(defaultVariants != nil && [defaultVariants indexOfObject:[[port valueForKey:@"variants"] objectAtIndex:i]] != NSNotFound)
			{
				//NSLog(@"Default %@", [[port valueForKey:@"variants"] objectAtIndex:i]);
				[checkboxes[i] setState:NSOnState];
				[checkboxes[i] setIsDefault:YES];
 			}
			else
			{
				[checkboxes[i] setState:NSOffState];
				[checkboxes[i] setIsDefault:NO];\
			}
			//Show all existing variants, and set their titles
			[checkboxes[i] setAlphaValue:1];
			NSAttributedString *tempString = [[NSAttributedString alloc]\
											  initWithString:[[port valueForKey:@"variants"] objectAtIndex:i]\
		attributes: [NSDictionary dictionaryWithObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName]];
			[checkboxes[i] setAttributedTitle:tempString];
			 
		}
		//NSLog(@"End of Variants");
		//Call setConflicts to initialize conflicting variants in the GUI
		[self setConflicts:port];

		[variantsPanel makeKeyAndOrderFront:self];
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
- (IBAction)revupgrade:(id)sender
{
    [tableController open:nil];
    [self queueOperation:@"revupgrade" portName:@"-" portObject:@"-" variants:0];
}

- (IBAction)reclaim:(id)sender
{
    [tableController open:nil];
    [self queueOperation:@"reclaim" portName:@"-" portObject:@"-" variants:0];
}

- (IBAction)diagnose:(id)sender
{
    [tableController open:nil];
    [self queueOperation:@"diagnose" portName:@"-" portObject:@"-" variants:0];
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

-(IBAction)clickCheckbox:(id)sender
{
	
	//Are we checking or unchecking the checkbox?
	BOOL enableDisable;
	if([sender state]==NSOnState)
	{
		enableDisable=NO;
	}
	else
	{
		enableDisable=YES;
	}
	
	for(UInt j=0;j<[[sender conflictsWith] count]; j++)
	{
		//If we are checking the checkbox, then disable and uncheck the conflicting ones
		//If we are unchecking the checkbox, enable the conflicting ones
		for(UInt i=0; i<10; i++)
		{
			if ([[checkboxes[i] title] isEqualToString:[[sender conflictsWith] objectAtIndex:j]])
			{
				[checkboxes[i] setEnabled:enableDisable];
				if (!enableDisable)
				{
					[checkboxes[i] setState:NSOffState];
				}
			}
		}		
	}
	 
}

-(void)setConflicts: (MPPort *) port
{	
	//Initialize the conflicts NSMutableArray for the port, if it wasn't already initialized
	[port checkConflicts];

	NSArray *conflicts = [port objectForKey:@"conflicts"];
	//For each conflict in the array, check which checkbox/variant has the same name as the conflict, and
	//call the setConflictsWith method to add the conflicting checkbox to the conflictsWith array
	for(UInt j=0; j< [conflicts count];j++)
	{
		UInt i;
		for( i=0; i<10; i++)
		{
			if ([[conflicts objectAtIndex:j] objectForKey:[checkboxes[i] title]] != nil)
			{
				break;
			}
		 }
		[checkboxes[i] setConflictsWith:[[conflicts objectAtIndex:j] objectForKey:[checkboxes[i] title]]];
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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existsAsDirectory = NO;
        BOOL containsMacPortsTcl = NO;
        NSString *macportsDir;
        NSString *macportsFile;
        macportsDir = [[MPMacPorts PKGPath] stringByAppendingPathComponent:@"macports1.0"];
        macportsFile = [macportsDir stringByAppendingPathComponent:@"macports.tcl"];
        [fileManager fileExistsAtPath:macportsDir isDirectory:&existsAsDirectory];
        if (existsAsDirectory) {
		    containsMacPortsTcl = [fileManager fileExistsAtPath:macportsFile isDirectory:nil];
	    }
        if (containsMacPortsTcl) {
            [defaults setObject:[MPMacPorts PKGPath] forKey:@"PKGPath"];
            [[MPActionLauncher sharedInstance]
                    performSelectorInBackground:@selector(loadPorts) withObject:nil];
        } else {
            [self openPreferences:self];
        }
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

//This is called when clicking on the 'start queue' button, or clicking on an operation while holding the alt key
-(void) startQueue:(id) sender
{
	NSLog(@"Starting Queue");
	NSUInteger index;
	index = [queueArray count]-1;
	NSLog(@"Array Size is: %lu", (unsigned long)index);
	[queue setSelectionIndex: 0];
	queueCounter=0;
	
	//We add ourselves as an observer in the Notification Center, and call advanceQueue whenever we receive an 'advanceQ' notification
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(advanceQueue)
												 name:@"advanceQ" object:nil];
	//We start the operations by advancing in the queue once. When that operation is completed, it will
	//automatically advance to the next queue by sending an advanceQ notification.
	[self advanceQueue];
}

//This method is called to move through the queue and perform all the operations one by one. Each time this method is called,
//we advance one spot in the queue
-(void) advanceQueue
{
	NSUInteger index=queueCounter;
	if([queueArray count]>index)
	{
		NSLog(@"Advancing Queue for %lu", (unsigned long)index);
		//index = [queue selectionIndex];
		NSLog(@"Index before: %lu", (unsigned long)index);

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
        else if([[dict objectForKey:@"operation"] isEqualToString:@"diagnose"])
        {
            NSLog(@"We have diagnose");
            [[MPActionLauncher sharedInstance] performSelectorInBackground:@selector(diagnose:) withObject:port];
        }
        else if([[dict objectForKey:@"operation"] isEqualToString:@"reclaim"])
        {
            NSLog(@"We have reclaim");
            [[MPActionLauncher sharedInstance] performSelectorInBackground:@selector(reclaim:) withObject:nil];
        }
        else if([[dict objectForKey:@"operation"] isEqualToString:@"revupgrade"])
        {
            NSLog(@"We have revupgrade");
            [[MPActionLauncher sharedInstance] performSelectorInBackground:@selector(revupgrade) withObject:nil];
        }
	}
	else
	{
		//If we are done, we remove ourselves as an observer from the Notification Center, and we notify the user
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"advanceQ" object:nil];
		
		//int allops=GROWL_ALLOPS;
        //FIXME
		//[[MPActionLauncher sharedInstance]
		 //performSelectorInBackground:@selector(sendGrowlNotification:) withObject:(id) allops];
		
	}

	queueCounter++;
	
}

//This method is called when adding a new operation on the queue. Its inputs are the operation to be performed, the port name, the 
//equivalent port object, and the variants
-(void) queueOperation:(NSString*)operation portName:(NSString*)name portObject: (id) port variants: (NSMutableArray*) variants
{
	//We set the operation's icon
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
    else if([operation isEqualToString:@"diagnose"])
    {
        image = [NSImage imageNamed:@"NSAdvanced"];
    }
    else if([operation isEqualToString:@"reclaim"])
    {
        image = [NSImage imageNamed:@"NSTrashFull"];
    }
    else if([operation isEqualToString:@"revupgrade"])
    {
        image = [NSImage imageNamed:@"NSCaution"];
    }
	
	//If we have variants, print them out for debugging purposes
	if(variants!=nil)
	{
		for(UInt i=0; i<[variants count]; i++)
		{
			NSLog(@"variants array at #%i: %@", i, [variants objectAtIndex:i]);
		}
	}
	
	NSLog(@"Queueing our Operation");
	//Add the operation to the queue
	[queue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:operation, @"operation", name, @"port", port, @"object", image, @"image", variants, @"variants", nil]];
}

-(void) removeFromQueue
{
	UInt index = [queue selectionIndex];
	[queue removeObjectAtArrangedObjectIndex:0];
	[queue setSelectionIndex: index];
}


//This is called when we have the alt key pressed, so that we clear the queue before adding and performing our new operation
-(void) clearQueue
{
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
