/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 *	George Armah <armahg@macports.org>
 *
 *	Copyright (c) 2008 George Armah <armahg@macports.org>
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

#import "MPMacPortsTest.h"


@implementation MPMacPortsTest
- (void) setUp {
	testPort = [MPMacPorts sharedInstance];
}

- (void) tearDown {
	[testPort release];
}


- (void) testPortCreation {
	STAssertNotNil(testPort, @"Should not be nil");
}


- (void) testPrefix {
	NSString *prefix = [testPort prefix];
	//Find out why prefix returns nil
	STAssertNotNil(prefix, @" %@ should not be nil", prefix);
}


-(void) testSources{	
	NSArray *sourcesArray = [testPort sources];
	STAssertNotNil(sourcesArray, @"Sources array should not be nil");
}

//Ask Randall about what exactly port tree path is
-(void) testPathToPortIndex {
	NSURL *pindex = [testPort pathToPortIndex:@"file:///Users/Armahg/macportsbuild/build1/"];
	STAssertNotNil(pindex, @"URL for port index should not be nil");
}

-(void) testSearch {
	NSDictionary *searchResults = [testPort search:@"/Users/Armahg"];
	STAssertNotNil(searchResults, @"This dictionary should have at least %d key value pairs", [searchResults count]);
}


-(void) testSync {
	NSError * syncError = nil;
	[testPort sync:&syncError];
	
	if(syncError) {
		//Attempt to recover from error by authenticating and then
		//running sync again. We are going to decide whether or not to
		//do this for clients of the Framework of have them do it themselves
		NSLog(@"Error is %@", [syncError description]);
	}
	
	
}

/*
-(void) testSelfupdate {
	//The only way to test this that I know of is to listen for the posted notifications
	//and take actions as appropriate
	[testPort selfUpdate];
	
}
*/

-(void) testVersion {
	NSString * version = [testPort version];
	STAssertNotNil(version, @"%@ should not be nil", version);
}




/*
-(void) testInstall {
	NSDictionary * result = [testPort search:@"pyt"];
	STAssertNotNil(result, @"Search dictionary should not be null");
	NSArray * aKeys = [result allKeys];
	//id key = [enuma nextObject];
	
	
	unsigned int a = [aKeys count];
	NSLog(@"%d size Dictionary", a);
	//STAssertNotNil(key , @"First object should not be null");
	
	/*NSEnumerator * enumerator = [result keyEnumerator];
	id key = [enumerator nextObject];
	MPPort * nwPort = [[MPPort alloc] initWithTclListAsString:[result objectForKey:key]];
	[testPort install:nwPort];
	[nwPort release];
}*/

@end
