//
//  MPCheckbox.h
//  Pallet
//
//  Created by Vasileios Georgitzikis on 21/7/10.
//  Copyright 2010 Tzikis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//MPCheckbox is a custom NSButton class, that we use for our variants checkboxes.
//Each variant is represented by a checkbox. This checkbox also stores wether it is a default variant, and a list of conflicting variants
@interface MPCheckbox : NSButton {

	
	BOOL isDefault;
	
	NSMutableArray *conflictsWith;
}

@property (nonatomic) BOOL isDefault;
@property (nonatomic, retain) NSMutableArray *conflictsWith;

@end
