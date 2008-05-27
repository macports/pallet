/*
	Class MPAuthority
	Project Pallet
 
	Copyright (C) 2006 MacPorts.
 
	This code is free software; you can redistribute it and/or modify it under
	the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
 
	This code is distributed in the hope that it will be useful, but WITHOUT ANY
	WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
	details.
 
	For a copy of the GNU General Public License, visit <http://www.gnu.org/> or
	write to the Free Software Foundation, Inc., 59 Temple Place--Suite 330,
	Boston, MA 02111-1307, USA.
 
	More information is available at http://www.macports.org or macports-users@lists.macosforge.org
 
	History:
	
	Created by Randall Wood rhwood@macports.org on 6 October 2006
 */

#import "PortAuthority.h"

#include <tcl.h>

@implementation PortAuthority

enum portCommands {
	portInstall,
	portList,
	portListAll,
	portSync,
	portSelfupdate,
	portListInstalled,
	portListOutdated
};

#pragma mark STARTUP

- (void)awakeFromNib
{
	// Get a MacPorts Interpeter
	macPorts = [MPMacPorts sharedInstance];
	// Register for notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willSetIndex:) name:MPIndexWillSetIndex object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetIndex:) name:MPIndexDidSetIndex object:nil];
	// Load/set preferences/defaults
	if (![[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"synchronizePortsListOnStartup"]) {
		NSString *userDefaultsValuesPath;
		NSDictionary *userDefaultsValuesDict;
		userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" 
																 ofType:@"plist"];
		userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
		[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
		[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:userDefaultsValuesDict];
	}
	// Hide duplicate items in Windows menu
	[portsWindow setExcludedFromWindowsMenu:YES];
	[portLogWindow setExcludedFromWindowsMenu:YES];
	// Locate port
	macPortsPort = [[NSString alloc] initWithString:[[macPorts prefix] stringByAppendingPathComponent:@"bin/port"]];
	// Initialize the port settings cache
	portSettings = [[NSMutableDictionary alloc] init];
	// Clean the main window
	//[status setStringValue:@""];
	// Setup the port task
	portIsRunning = NO;
	launcher = [[NSBundle mainBundle] pathForResource:@"Launcher" ofType:nil];
	agentTask = [[AuthorizedExecutable alloc] initWithExecutable:launcher];
	authPortTask = [[AuthorizedExecutable alloc] initWithExecutable:launcher];
	killTask = [[AuthorizedExecutable alloc] initWithExecutable:launcher];
	[agentTask setDelegate:self];
	[authPortTask setDelegate:self];
	[killTask setDelegate:self];
	// Setup the value transformers used in bindings
	NSValueTransformer *transformer = [[PAStatusTransformer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"PAStatusTransformer"];
	// UI Tweaks
	[[portsList headerView] setMenu:portsListHeaderMenu];
	[[portsList cornerView] setMenu:portsListHeaderMenu];
	// setup the displayed index
	portsListIndex = [[NSMutableArray alloc] init];
	// START TESTING START TESTING START TESTING
	//NSLog([[[MPRegistry sharedRegistry] installed:@"nonesuch"] description]);
	//NSLog([[[MPRegistry sharedRegistry] installed:@"gtk2"] description]);
	// END TESTING END TESTING END TESTING
}

/*
	TODO: rewrite to run sync/selfupdate, and port list methods in thread so as not to block UI.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// sync or selfupdate as required
	if ([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"updateMacPortsOnStartup"] boolValue] == YES) {
		[self updateMacPorts:nil];
	} else if ([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"synchronizePortsListOnStartup"] boolValue] == YES) {
		[self syncPortsList:nil];
	}
	// List ports
	portsIndex = [[MPIndex alloc] init];
	[portIndexController setContent:[portsIndex allValues]];
}

/*
#pragma mark PORT INDEX

- (void)populatePortIndex
{
	NSEnumerator *indexEnumerator;
	id index;
	if (portIndex = nil) {
		portIndex = [[NSMutableArray alloc] init];
	}
	indexEnumerator = [[macPorts sources] objectEnumerator];
	while (index = [indexEnumerator nextObject]) {
}

- (void)indexPortsInThread
{
	
}
*/
#pragma mark PORT COMMANDS

- (void)defaultAction:(id)items
/*
 rewrite to use other methods in this class to avoid duplication
 */
{
	id item;
	switch ([[item valueForKey:@"state"] intValue]) {
		case MPPortStateActive:
			[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
				@"uninstall",
				@"-dv",
				[item valueForKey:@"name"]]];
			break;
		case MPPortStateInstalled:
			[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
				@"activate",
				@"-dv",
				[item valueForKey:@"name"]]];
			break;
		case MPPortStateOutdated:
			[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
				@"upgrade",
				@"-dv",
				[item valueForKey:@"name"]]];
			break;
		case MPPortStateUnknown:
		case MPPortStateNotInstalled:
			[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
				@"install",
				@"-dv",
				[item valueForKey:@"name"]]];
			break;
		default:
			break;
	}
}

- (IBAction)installPort:(id)sender
{
	portCommand = portInstall;
	NSArray *selection = [portIndexController selectedObjects];
	NSEnumerator *selectionEnumerator = [selection objectEnumerator];
	id port;
	while (port = [selectionEnumerator nextObject]) {
		[self installSinglePort:[port objectForKey:@"name"]];
	}
}

- (void)installSinglePort:(NSString *)port
{
	[status setStringValue:[NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"statusInstallPort",
															 @"Localizable",
															 [NSBundle mainBundle],
															 @"Preparing to install %@",
															 @"Status for [MPAuthority installPort] method"),
		port]];
	NSLog([status stringValue]);
	[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
		@"-dv",
		@"install",
		port,
		nil]];
}

- (IBAction)reinstallPort:(id)sender
{
}

- (IBAction)removePort:(id)sender
{
}

- (IBAction)syncPortsList:(id)sender
{
	portCommand = portSync;
	[status setStringValue:NSLocalizedStringWithDefaultValue(@"statusSyncPortsList",
															 @"Localizable",
															 [NSBundle mainBundle],
															 @"Syncing ports list with MacPorts",
															 @"Status for [MPAuthority syncPortsList] method")]; 
	[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
		@"sync",
		@"-dv",
		nil]];
}

- (IBAction)updateMacPorts:(id)sender
{
	portCommand = portSelfupdate;
	[status setStringValue:NSLocalizedStringWithDefaultValue(@"statusUpdateMacPorts",
															 @"Localizable",
															 [NSBundle mainBundle],
															 @"Updating MacPorts Installation",
															 @"Status for [MPAuthority updateMacPorts] method")]; 
	[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
		@"selfupdate",
		nil]];
}

- (IBAction)upgradeOutdated:(id)sender
{
	NSLog(@"Upgrade Outdated\n");
	portCommand = portSelfupdate;
	[status setStringValue:NSLocalizedStringWithDefaultValue(@"statusUpgradeOutdated",
															 @"Localizable",
															 [NSBundle mainBundle],
															 @"Preparing to upgrade all outdated ports...",
															 @"Status for [MPAuthority upgradeOutdated] method")];
	[self launchAuthorizedExecutableWithArguments:[NSArray arrayWithObjects:macPortsPort,
		@"-dv",
		@"upgrade",
		@"outdated",
		nil]];
}

- (IBAction)upgradePort:(id)sender
{
}

- (IBAction)haltPortCommand:(id)sender
{
	
}

- (void)runPortCommand:(NSString *)action port:(NSString *)port
{
	
}



- (void)runPortCommandInThread:(id)parameters
{
	
}

#pragma mark SELECTORS

- (void)didSetIndex:(NSNotification *)notification {
	[status setStringValue:@""];
	[progressIndicator stopAnimation:nil];
}

- (void)willSetIndex:(NSNotification *)notification {
	[status setStringValue:NSLocalizedStringWithDefaultValue(@"statusSetIndex",
															 @"Localizable",
															 [NSBundle mainBundle],
															 @"Reading list of ports...(one less NSString)",
															 @"Status while setting Index")
		];
	[progressIndicator startAnimation:nil];
}

#pragma mark TABLES

- (void)updateAvailablePorts:(id)output
{
	NSLog(output);
	NSMutableArray *fields;
	NSMutableDictionary *columns;
	columns = [[NSMutableDictionary alloc] initWithCapacity:4];
	fields = [[NSMutableArray alloc] initWithArray:[output componentsSeparatedByString:@" "]];
	[fields removeObjectIdenticalTo:[NSString string]];
	[columns setValue:[NSNumber numberWithInt:MPPortStateUnknown] forKey:@"state"];
	[columns setValue:[fields objectAtIndex:0] forKey:@"name"];
	[columns setValue:[fields objectAtIndex:1] forKey:@"version"];
	[columns setValue:[fields objectAtIndex:2] forKey:@"categories"];
	[portsListIndex addObject:columns];
	[portsList reloadData];
}

#pragma mark TABLE DATASOURCES

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSLog(@"request for row %@ column %@\n", [NSNumber numberWithInt:rowIndex], [aTableColumn identifier]);
	NSParameterAssert(rowIndex >= 0 && rowIndex < [portsListIndex count]);
	if ([[[aTableColumn identifier] stringValue] isEqualToString:@"state"]) {
		switch ([[[portsListIndex objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]] intValue]) {
			case MPPortStateInstalled:
				return nil;
				break;
			case MPPortStateActive:
				return nil;
				break;
			case MPPortStateOutdated:
				return nil;
				break;
			default:
				return nil;
		}
	}
	return [[portsListIndex objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [portsListIndex count];
}

#pragma mark MENU ITEMS

- (IBAction)about:(id)sender
{
	NSMutableDictionary *options;
	NSMutableAttributedString *credits;
	
	credits = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:
		NSLocalizedStringFromTable(@"MacPorts Version: %@",
								   @"Localizable",
								   @"MacPorts Version"),
		[macPorts version]]];
	
	[credits setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [credits length])];
	[credits addAttribute:@"NSFontAttributeName" value:[NSFont labelFontOfSize:[NSFont labelFontSize]] range:NSMakeRange(0, [credits length])];
	options = [[NSMutableDictionary alloc] init];
	[options setObject:credits forKey:@"Credits"];
	[NSApp orderFrontStandardAboutPanelWithOptions:options];
}

- (IBAction)macPortsSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.macports.org"]];
}

- (IBAction)palletSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.macports.org"]];
}

#pragma mark UTILITIES

- (void)launchExecutableWithArguments:(NSMutableArray *)args
{
	if (!portIsRunning) {
		portIsRunning = YES;
		[NSApp setApplicationIconImage:[NSImage imageNamed:@"ApplicationIconBusy"]];
		if (portTask != nil) {
			[portTask release];
		}
		portTask = [[TaskWrapper alloc] initWithController:self arguments:args];
		[portTask startProcess];
	}
}

- (void)launchAuthorizedExecutableWithArguments:(NSMutableArray *)args
{
	NSLog(@"Launching command %@", args);
	if (!portIsRunning) {
		portIsRunning = YES;
		[NSApp setApplicationIconImage:[NSImage imageNamed:@"ApplicationIconBusy"]];
		[authPortTask setArguments:args];
		[authPortTask authorizeWithQuery];
		[progressIndicator startAnimation:nil];
		[authPortTask start];
	} else {
		[taskQueue addObject:args];
	}
}

#pragma mark TOOLBAR

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	return YES;
}

#pragma mark AUTHORIZED EXECUTABLE DELEGATES / TASK WRAPPER CONTROLLER
// This callback is implemented as part of conforming to the ProcessController protocol.
// It will be called whenever there is output from the TaskWrapper.
- (void)appendOutput:(NSString *)output
{
    // add the string (a chunk of the results from locate) to the NSTextView's
    // backing store, in the form of an attributed string
    [[portLog textStorage] appendAttributedString: [[[NSAttributedString alloc]
                             initWithString: output] autorelease]];
    // setup a selector to be called the next time through the event loop to scroll
    // the view to the just pasted text.  We don't want to scroll right now,
    // because of a bug in Mac OS X version 10.1 that causes scrolling in the context
    // of a text storage update to starve the app of events
    [self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];
	switch (portCommand) {
	}
}

// This routine is called after adding new results to the text view's backing store.
// We now need to scroll the NSScrollView in which the NSTextView sits to the part
// that we just added at the end
- (void)scrollToVisible:(id)ignore {
    [portLog scrollRangeToVisible:NSMakeRange([[portLog string] length], 0)];
}

// A callback that gets called when a TaskWrapper is launched, allowing us to do any setup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processStarted
{
    portIsRunning = YES;
    [portLog setString:@""];
	[progressIndicator startAnimation:nil];
}

// A callback that gets called when a TaskWrapper is completed, allowing us to do any cleanup
// that is needed from the app side.  This method is implemented as a part of conforming
// to the ProcessController protocol.
- (void)processFinished
{
    portIsRunning = NO;
	[status setStringValue:@""];
	[progressIndicator stopAnimation:nil];
	if ([taskQueue count]) {
		[self launchAuthorizedExecutableWithArguments:[taskQueue objectAtIndex:0]];
		[taskQueue removeObjectAtIndex:0];
	}
}

- (void)captureOutput:(NSString*)str forExecutable:(AuthorizedExecutable*)exe
{
	NSRange marker, eol;
    [[portLog textStorage] appendAttributedString: [[[NSAttributedString alloc]
                             initWithString: str] autorelease]];
	@try {
		marker = [str rangeOfString:@"--->"];
		eol = [str rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(marker.location + 4, [str length] - marker.location)];
		NSLog([str substringWithRange:NSMakeRange(marker.location + 4, eol.location - (marker.location + 4))]);
	}		
	@catch (NSException *exception) {
		// Exceptions will be thrown where "--->" is not in str
		// Ignore the exceptions since we want to change the status line only if such a line exists
	}
    [self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];
}

- (void)executableFinished:(AuthorizedExecutable *)exe withStatus:(int)exeStatus
{
	NSLog(@"Launcher finished with status %u", exeStatus);
	portIsRunning = NO;
	[status setStringValue:@""];
	[progressIndicator stopAnimation:nil];
	if ([taskQueue count]) {
		[self launchAuthorizedExecutableWithArguments:[taskQueue objectAtIndex:0]];
		[taskQueue removeObjectAtIndex:0];
	}
}

#pragma mark APPLICATION DELEGATES

-(void)applicationWillTerminate:(NSNotification*)anotification
{
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"ApplicationIcon"]];
    [authPortTask unAuthorize];
	[killTask unAuthorize];
}

@end
