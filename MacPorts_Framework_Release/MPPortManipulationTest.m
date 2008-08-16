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
	NSDictionary * searchResult = [mainPort search:@"pngcrush"];
	NSArray * keyArray = [searchResult allKeys];
	//NSLog(@"\n\nPrinting search results for \"sphinx\"");
	
	//NSLog(@" %@ ", keyArray);
	//NSLog(@" %@ ", [searchResult allValues]);
	
	id key;
	NSEnumerator * k = [searchResult keyEnumerator];
	while ( key = [k nextObject]) {
		//NSLog(@"\n\n Key: %@ \n\n MPPort object: %@ \n\n", key, [searchResult objectForKey:key]);
	}
	
	//NSLog(@"\n\nDone searching for \"sphinx\"\n\n");
	
	NSLog(@"\n\n Installing first result from search %@ \n\n", [searchResult objectForKey:[keyArray objectAtIndex:0]]);
	NSError * iError;
	[[searchResult objectForKey:[keyArray objectAtIndex:0]] installWithOptions:nil variants:nil error:&iError];
	
	//How do we check if a port is installed? Should the methods return BOOL's instead?
	if (iError != nil) {
		NSLog(@"\n\n Installation of %@ failed \n\n", [keyArray objectAtIndex:0]);
	}
	else{
		NSLog(@"\n\n Installation successful \n\n");
		//Double check somehow
		MPRegistry * registry = [MPRegistry sharedRegistry];
		NSLog(@"\n\n Result from registry is %@ \n\n", [registry installed:[keyArray objectAtIndex:0]]);
		
	}
	
}

@end
