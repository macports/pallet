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

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>
#import "MPPortsController.h"
#import "PAStatusTransformer.h"
#import "TaskWrapper.h"
#import "AuthorizedExecutable.h"
//#import "MPAgentProtocol.h"
//#import "MPInterp.h"
//#import "MPObject.h"

@interface PortAuthority : NSObject <TaskWrapperController>

{
	
    IBOutlet NSTableView *portsList;
    IBOutlet NSTextView *portInfo;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *status;
	IBOutlet NSTextView *portLog;
	IBOutlet NSWindow *portsWindow;
	IBOutlet NSWindow *portLogWindow;
	IBOutlet MPPortsController *portIndexController;
	IBOutlet NSMenu *portsListHeaderMenu;
	
//	IBOutlet NSTextField *portInstallationPath; // this needs to be set correctly first run to ensure that
												// the preference gets stored

	NSConnection *connection;
//	id <MPAgentProtocol> agent;
	BOOL agentIsBusy;
	
	NSMutableArray *portsListIndex;
	
	NSMutableArray *taskQueue;
	BOOL portIsRunning;
	TaskWrapper *portTask;
	int portCommand;
	NSString *lastOutput;
	NSString *launcher;
	NSString *macPortsPort;
	AuthorizedExecutable *agentTask;
	AuthorizedExecutable *authPortTask;
	AuthorizedExecutable *killTask;
	NSMutableDictionary *portSettings;
	NSMutableDictionary *dependencies;
	NSMutableArray *operations;

	MPIndex *portsIndex;
	MPMacPorts *macPorts;
}

- (IBAction)installPort:(id)sender;
- (IBAction)reinstallPort:(id)sender;
- (IBAction)removePort:(id)sender;
- (IBAction)syncPortsList:(id)sender;
- (IBAction)updateMacPorts:(id)sender;
- (IBAction)upgradeOutdated:(id)sender;
- (IBAction)upgradePort:(id)sender;
- (IBAction)haltPortCommand:(id)sender;

- (void)installSinglePort:(NSString *)name;
- (void)runPortCommand:(NSString *)action port:(NSString *)port;
- (void)runPortCommandInThread:(id)parameters;

- (IBAction)about:(id)sender;
- (IBAction)macPortsSite:(id)sender;
- (IBAction)palletSite:(id)sender;

- (void)didSetIndex:(NSNotification *)notification;
- (void)willSetIndex:(NSNotification *)notification;
	

- (void)launchExecutableWithArguments:(NSMutableArray *)args;
- (void)launchAuthorizedExecutableWithArguments:(NSMutableArray *)args;

@end
