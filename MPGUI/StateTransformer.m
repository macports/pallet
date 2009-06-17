//
//  StateTransformer.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/16/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "StateTransformer.h"


@implementation StateTransformer

+ (Class)transformedValueClass
{ 
	return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO;
}

- (id)transformedValue:(id)value 
{
	if (value == nil) {
		return nil;
	} else {
		switch ([value intValue]) {
			case MPPortStateUnknown:
			case MPPortStateNotInstalled:
				return nil;
				break;
			case MPPortStateActive:
				return [NSImage imageNamed:@"Installed.tiff"];
				break;
			case MPPortStateInstalled:
				return [NSImage imageNamed:@"Installed.tiff"];
				break;
			case MPPortStateOutdated:
				return [NSImage imageNamed:@"Outdated.tiff"];
				break;
			default:
				return nil;
		}
	}
}

@end
