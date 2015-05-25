//
//  MPHelperToolTest.m
//  MacPorts.Framework
//
//  Created by George  Armah on 8/5/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import "MPHelperToolTest.h"


@implementation MPHelperToolTest

-(void) setUp {
	interp = [MPInterpreter sharedInterpreter];
}

-(void) tearDown {
	
}

//- (void) testMPHelperToolWithoutRights {
//	AuthorizationRef authRef;
//	
//		
//	OSStatus junk;
//	
//	
//	junk = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
//	assert(junk == noErr);
//	
//	[interp setAuthorizationRef:authRef];
//	
//	NSString * result = [interp evaluateStringWithMPHelperTool:@"mportsync"];
//	
//	NSLog(@"Result is %@" , result);
//	STAssertTrue ( [result isEqualToString:@"TCL COMMAND EXECUTION SUCCEEDED YAAY!:"], \
//				  @"Result should succeed so long as we enter credentials");	
//}
//

@end
