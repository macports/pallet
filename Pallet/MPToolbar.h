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

#import <Cocoa/Cocoa.h>

@class MPAuthority;

@interface MPToolbar : NSObject {

	IBOutlet NSWindow *ports;
	IBOutlet MPAuthority *pallet;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSView *searchView;

	NSMutableDictionary *toolbarItems;
	NSToolbarItem *toolbarSearchItem;

	
	
}

- (IBAction)search:(id)sender;

- (BOOL)validateMenuItem:(NSMenuItem*)anItem;

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
- (void)addItemToToolbar:(NSString *)identifier
				   label:(NSString *)label
			paletteLabel:(NSString *)paletteLabel
				 toolTip:(NSString *)toolTip
				  target:(id)target
				  action:(SEL)action
		 settingSelector:(SEL)settingSelector
			 itemContent:(id)itemContent
					menu:(NSMenu *)menu;


@end
