/*
	Class MPToolbar
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

#import "MPToolbar.h"


@implementation MPToolbar

- (void)awakeFromNib
{
	[[searchField cell] setSearchMenuTemplate:[[searchField cell] searchMenuTemplate]];
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:@"myToolbar"] autorelease];
	toolbarItems = [[NSMutableDictionary dictionary] retain];
	toolbarSearchItem = [[[NSToolbarItem alloc] init] retain];
	[self addItemToToolbar:@"Install"
					 label:NSLocalizedString(@"Install", @"Install label")
			  paletteLabel:NSLocalizedString(@"Install Port", @"Install paletteLabel")
				   toolTip:NSLocalizedString(@"Install the selected port", @"Install toolTip")
					target:pallet
					action:@selector(installPort:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Install.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Remove"
					 label:NSLocalizedString(@"Remove", @"Remove label")
			  paletteLabel:NSLocalizedString(@"Remove Port", @"Remove paletteLabel")
				   toolTip:NSLocalizedString(@"Remove the selected port", @"Remove toolTip")
					target:pallet
					action:@selector(removePort:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Remove.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Halt"
					 label:NSLocalizedString(@"Halt", @"Halt label")
			  paletteLabel:NSLocalizedString(@"Halt Command", @"Halt paletteLabel")
				   toolTip:NSLocalizedString(@"Halt the command being executed", @"Halt toolTip")
					target:pallet
					action:@selector(halt:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Halt.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Sync"
					 label:NSLocalizedString(@"Sync", @"Sync label")
			  paletteLabel:NSLocalizedString(@"Sync Ports List", @"Sync paletteLabel")
				   toolTip:NSLocalizedString(@"Synchronize the list of available ports", @"Sync toolTip")
					target:pallet
					action:@selector(syncPortsList:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Sync.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Upgrade"
					 label:NSLocalizedString(@"Upgrade", @"Upgrade label")
			  paletteLabel:NSLocalizedString(@"Upgrade Port", @"Upgrade paletteLabel")
				   toolTip:NSLocalizedString(@"Upgrade the selected port", @"Upgrade toolTip")
					target:pallet
					action:@selector(upgradePort:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Upgrade.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Update"
					 label:NSLocalizedString(@"Update", @"Update label")
			  paletteLabel:NSLocalizedString(@"Update MacPorts", @"Update paletteLabel")
				   toolTip:NSLocalizedString(@"Update the MacPorts infrastructure", @"Update toolTip")
					target:pallet
					action:@selector(updateMacPorts:)
		   settingSelector:@selector(setImage:)
			   itemContent:[NSImage imageNamed:@"Update.tiff"]
					  menu:NULL];
	[self addItemToToolbar:@"Search"
					 label:NSLocalizedString(@"Search", @"Search label")
			  paletteLabel:NSLocalizedString(@"Search Ports", @"Search paletteLabel")
				   toolTip:NSLocalizedString(@"Search for a port", @"Search toolTip")
					target:pallet
					action:NULL
		   settingSelector:@selector(setView:)
			   itemContent:searchView
					  menu:NULL];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration: YES]; 
    [toolbar setDisplayMode: NSToolbarDisplayModeDefault];
    [ports setToolbar:toolbar];
}

- (void) dealloc
{
    [toolbarItems release];
	[toolbarSearchItem release];
    [super dealloc];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item = [toolbarItems objectForKey:itemIdentifier];
    
    [newItem setLabel:[item label]];
    [newItem setPaletteLabel:[item paletteLabel]];
    if ([item view] != NULL) {
		[newItem setView:[item view]];
    } else {
		[newItem setImage:[item image]];
    }
    [newItem setToolTip:[item toolTip]];
    [newItem setTarget:[item target]];
    [newItem setAction:[item action]];
    [newItem setMenuFormRepresentation:[item menuFormRepresentation]];
    // If we have a custom view, we *have* to set the min/max size - otherwise, it'll default to 0,0 and the custom
    // view won't show up at all!  This doesn't affect toolbar items with images, however.
    if ([newItem view] != NULL) {
		[newItem setMinSize:[[item view] bounds].size];
		[newItem setMaxSize:[[item view] bounds].size];
    }
	// Grab a reference to the search item so we can manipulate its label
	if ([itemIdentifier isEqualToString:@"Search"]) {
		[toolbarSearchItem release];
		toolbarSearchItem = newItem;
	}
    return newItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
		@"Install",
		@"Remove",
		@"Upgrade",
		NSToolbarSeparatorItemIdentifier,
		@"Sync",
		@"Halt",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"Search",
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
		@"Install",
		@"Remove", 
		@"Halt",
		@"Search",
		@"Sync",
		@"Update",
		@"Upgrade",
		NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	return YES;
}

- (void)addItemToToolbar:(NSString *)identifier
				   label:(NSString *)label
			paletteLabel:(NSString *)paletteLabel
				 toolTip:(NSString *)toolTip
				  target:(id)target
				  action:(SEL)action
		 settingSelector:(SEL)settingSelector
			 itemContent:(id)itemContent
					menu:(NSMenu *)menu
{
    NSMenuItem *menuItem;
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item performSelector:settingSelector withObject:itemContent];
    [item setAction:action];
    if (menu != NULL) {
		menuItem=[[[NSMenuItem alloc] init] autorelease];
		[menuItem setSubmenu: menu];
		[menuItem setTitle: [menu title]];
		[item setMenuFormRepresentation:menuItem];
    }
    [toolbarItems setObject:item forKey:identifier];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	return YES;
}

- (IBAction)search:(id)sender
{
	
}

@end
