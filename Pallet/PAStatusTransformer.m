//
//  PAStatusTransformer.m
//  Pallet
//
//  Created by Randall Hansen Wood on 13/1/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAStatusTransformer.h"


@implementation PAStatusTransformer

+ (Class)transformedValueClass
{
	return [NSString self];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)beforeObject
{
	if (beforeObject == nil) return nil;
	id resourcePath = [[NSBundle mainBundle] resourcePath];
	switch ([beforeObject intValue]) {
		case MPPortStateUnknown:
		case MPPortStateNotInstalled:
			return nil;
			break;
		case MPPortStateActive:
			return [resourcePath stringByAppendingPathComponent:@"Installed.tiff"];
			break;
		case MPPortStateInstalled:
			return [resourcePath stringByAppendingPathComponent:@"Installed.tiff"];
			break;
		case MPPortStateOutdated:
			return [resourcePath stringByAppendingPathComponent:@"Outdated.tiff"];
			break;
	}
	return nil;
}

@end
