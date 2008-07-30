/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 * 	Randall H. Wood <rhwood@macports.org>
 *
 *	Copyright (c) 2007 Randall H. Wood <rhwood@macports.org>
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions
 *	are met:
 *	1.	Redistributions of source code must retain the above copyright
 *		notice, this list of conditions and the following disclaimer.
 *	2.	Redistributions in binary form must reproduce the above copyright
 *		notice, this list of conditions and the following disclaimer in the
 *		documentation and/or other materials provided with the distribution.
 *	3.	Neither the name of the copyright owner nor the names of contributors
 *		may be used to endorse or promote products derived from this software
 *		without specific prior written permission.
 * 
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 *	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
						   *	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
						   *	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *	POSSIBILITY OF SUCH DAMAGE.
 */

#import "MPInterpreterTest.h"


@implementation MPInterpreterTest

- (void)setUp {
	interp = [MPInterpreter sharedInterpreter];
}

- (void)tearDown {
	[interp release];
}

- (void)testInitialization {
	STAssertNotNil(interp, @"Should not be nil");	
}


- (void)testGetVariableAsArray {
	//unsigned int aSize = [[interpreter getVariableAsArray:@"macports::sources"] count];
	unsigned int aSize = 1;
	STAssertEquals([[interp getVariableAsArray:@"macports::sources"] count], aSize, @"Empty array returned when should have at least %d element.", aSize);
}
 

/*
- (void)testMPHelperTool {
	
	//Interesting ... we'll see who MPInterpreter belongs to
	//at the time of execution MPHelperTool ... or MacPorts.Framework
	[interp execute:[[NSBundle bundleForClass:MPInterpreter] pathForResource:@"MPHelperTool" ofType:nil] 
		   withArgs:[NSArray arrayWithObjects:@"--sel-repair", @"no", @"--rec-count", 
					 @"0", @"mportselfupdate", nil]];
}

/*
 Having trouble coming up with test cases for the methods below. Speak to Randall
 about that.
 *
- (void)testMutableDictionaryFromTclListAsString {
	
}
- (void)testEvaluateStringAsString {
	
}
*/

@end
