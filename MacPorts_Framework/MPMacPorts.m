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

#import "MPMacPorts.h"
#import "MPNotifications.h"


@implementation MPMacPorts


- (id) init {
	return [self initWithPkgPath:MP_DEFAULT_PKG_PATH];
}


- (id) initWithPkgPath:(NSString *)path {
	if (self = [super init]) {
		interpreter = [MPInterpreter sharedInterpreterWithPkgPath:path];
		[self registerForLocalNotifications];
	}
	return self;
}

+ (MPMacPorts *)sharedInstance {
	return [self sharedInstanceWithPkgPath:MP_DEFAULT_PKG_PATH];
}

+ (MPMacPorts *)sharedInstanceWithPkgPath:(NSString *)path {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"] == nil) {
			[[self alloc] initWithPkgPath:path]; // assignment not done here
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"];
}




+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"] == nil) {
			[[[NSThread currentThread] threadDictionary] setObject:[super allocWithZone:zone] forKey:@"sharedMPMacPorts"];
			return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"];	// assignment and return on first allocation
		}
	}
	return nil;	// subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma MacPorts API

- (void)sync {
	// This needs to throw an exception if things don't go well
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPortsSyncStarted" object:nil];
	[[MPNotifications sharedListener] setPerformingTclCommand:@"YES_sync"];
	
	[interpreter evaluateStringAsString:@"mportsync"];
	
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPortsSyncFinished" object:nil];
}

- (void)selfUpdate {
	//Also needs to throw an exception if things don't go well
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPortsSelfupdateStarted" object:nil];
	[[MPNotifications sharedListener] setPerformingTclCommand:@"YES_selfUpdate"];
	
	[interpreter evaluateStringAsString:@"macports::selfupdate"];
	
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPortsSelfupdateFinished" object:nil];
}


- (NSDictionary *)search:(NSString *)query {
	return [self search:query caseSensitive:YES];
}

- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)isCasesensitive {
	return [self search:query caseSensitive:isCasesensitive matchStyle:@"regex"];
}

- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)sensitivity matchStyle:(NSString *)style {
	return [self search:query caseSensitive:sensitivity matchStyle:style field:@"name"];
}

- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)sensitivity matchStyle:(NSString *)style field:(NSString *)fieldName {
	//Should I notify for searches? Will do for now just in case
	//[[MPNotifications sharedListener] setPerformingTclCommand:@"YES_search"];
	
	NSMutableDictionary *result, *newResult;
	NSEnumerator *enumerator;
	id key;
	NSString *caseSensitivity;
	if (sensitivity) {
		caseSensitivity = @"yes";
	} else {
		caseSensitivity = @"no";
	}
	result = [NSMutableDictionary dictionaryWithDictionary:
			  [interpreter dictionaryFromTclListAsString:
			   [interpreter evaluateArrayAsString:
				[NSArray arrayWithObjects:
										  @"return [mportsearch",
										  query,
										  caseSensitivity,
										  style,
										  fieldName,
										  @"]",
										  nil]]]];
	
	newResult = [NSMutableDictionary dictionaryWithCapacity:[result count]];
	enumerator = [result keyEnumerator];
	while (key = [enumerator nextObject]) {
		[newResult setObject:[[MPPort alloc] initWithTclListAsString:[result objectForKey:key]] forKey:key];
	}
	
	//[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	return [NSDictionary dictionaryWithDictionary:newResult];
}

- (NSArray *)depends:(MPPort *)port {
	return [port depends];
}


- (void)exec:(MPPort *)port withTarget:(NSString *)target withOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[port exec:target withOptions:options withVariants:variants];
}

#pragma settings

- (NSString *)prefix {
	if (prefix == NULL) {
		prefix = [interpreter getVariableAsString:@"macports::prefix_frozen"];
	}
	return prefix;
}

- (NSArray *)sources:(BOOL)refresh {
	if (refresh) {
		[sources release];
	}
	return [self sources];
}

- (NSArray *)sources {
	if (sources == nil) {
		sources = [interpreter getVariableAsArray:@"macports::sources"];
	}
	return sources;
}


- (NSURL *)pathToPortIndex:(NSString *)source {
	return [NSURL fileURLWithPath:
			[interpreter evaluateStringAsString:
			 [NSString stringWithFormat:@"return [macports::getindex %@ ]", source]]];
}


- (NSString *)version {
	if (version == nil) {
		version = [interpreter evaluateStringAsString:@"return [macports::version]"];
	}
	return version;
}

#pragma mark Testing MacPorts Notifications
-(void) registerForLocalNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPINFO
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPMSG
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPERROR
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPWARN
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:@"testMacPortsNotification"
											   object:nil];
}

-(void) respondToLocalNotification:(NSNotification *)notification {
	id sentDict = [notification userInfo];
	
	//Just NSLog it for now
	if(sentDict == nil)
		NSLog(@"Looooocaaaaal");
	else
		NSLog(@"%@" , [sentDict description]);
}

@end
