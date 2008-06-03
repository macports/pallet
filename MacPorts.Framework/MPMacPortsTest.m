//
//  MPMacPortsTest.m
//  MacPorts.Framework
//
//  Created by George  Armah on 6/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MPMacPortsTest.h"


@implementation MPMacPortsTest
- (void) setUp {
	testPort = [[MPMacPorts alloc] init];
}

- (void) tearDown {
	[testPort release];
}


- (void) testPortCreation {
	STAssertNotNil(testPort, @"Should not be nil");
}


- (void) testPrefix {
	NSString *prefix = [testPort prefix];
	STAssertNotNil(prefix, @" %@ should not be nil", prefix);
	[prefix release];
}

@end
