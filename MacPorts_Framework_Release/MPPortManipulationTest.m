//
//  MPPortManipulationTest.m
//  MacPorts.Framework
//
//  Created by George  Armah on 8/14/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import "MPPortManipulationTest.h"



@implementation MPPortManipulationTest

-(void) setUp {
	mainPort = [MPMacPorts sharedInstance];
}

-(void) tearDown {
	
}

-(void) testSimpleSearch {
	NSDictionary * searchResult = [mainPort search:@"sphinx"];
	NSLog(@"\n\nPrinting search results for \"sphinx\"");
	
	NSLog(@" %@ ", [searchResult allKeys]);
	NSLog(@" %@ ", [searchResult allValues]);
	
	id key;
	NSEnumerator * k = [searchResult keyEnumerator];
	while ( key = [k nextObject]) {
		NSLog(@"\n\n Key: %@ \n\n MPPort object: %@ \n\n", key, [searchResult objectForKey:key]);
	}
	
	NSLog(@"\n\nDone searching for \"sphinx\"\n\n");
}

@end
