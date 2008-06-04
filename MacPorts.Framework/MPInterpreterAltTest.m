//
//  MPInterpreterAltTest.m
//  MacPorts.Framework
//
//  Created by George  Armah on 6/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MPInterpreterAltTest.h"


@implementation MPInterpreterAltTest
- (void) setUp {
	interpreter = [MPInterpreterAlt sharedInterpreter];
}

- (void) tearDown {
	[interpreter release];
}

- (void)testSharedInterpreter {
	STAssertNotNil(interpreter, @"Should not be nil");
}

/*
- (void)testGetVariableArray {
	STAssertEquals([[interpreter getVariableAsArray:@"macports::sources"] count], 0, @"Empty array returned when should have at least 1 element.");
}
*/
@end
