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

static NSString* PKGPath;

@implementation MPMacPorts

+ (void) initialize {
	PKGPath = MP_DEFAULT_PKG_PATH;
}

+ (void) setPKGPath: (NSString*) path {
	PKGPath = path;
}

- (id) init {
	return [self initWithPkgPath:MP_DEFAULT_PKG_PATH portOptions:nil];
}


- (id) initWithPkgPath:(NSString *)path portOptions:(NSArray *)options {
	if (self = [super init]) {
		interpreter = [MPInterpreter sharedInterpreterWithPkgPath:path portOptions:nil];
		//[self registerForLocalNotifications];
	}
	return self;
}

+ (MPMacPorts *)sharedInstance {
	return [self sharedInstanceWithPkgPath:PKGPath];
}

+ (MPMacPorts *)sharedInstanceWithPortOptions:(NSArray *)options {
	return [self sharedInstanceWithPkgPath:PKGPath portOptions:options];
}

+ (MPMacPorts *)sharedInstanceWithPkgPath:(NSString *)path portOptions:(NSArray *)options {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"] == nil) {
			[[self alloc] initWithPkgPath:path portOptions:options ]; // assignment not done here
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"];
}

+ (MPMacPorts *)sharedInstanceWithPkgPath:(NSString *)path {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"] == nil) {
			[[self alloc] initWithPkgPath:path portOptions:nil ]; // assignment not done here
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPMacPorts"];
}

- (BOOL) setPortOptions:(NSArray *)options {
	return [interpreter setOptionsForNewTclPort:options];
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



- (id)sync:(NSError**)sError {
	NSString * result = nil;
	
	// This needs to throw an exception if things don't go well
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPorts_sync_Started" object:nil];
	[[MPNotifications sharedListener] setPerformingTclCommand:@"sync"];
	
	if ([self authorizationMode])
		result = [interpreter evaluateStringWithMPHelperTool:@"mportsync" error:sError];
	else
		result = [interpreter evaluateStringWithPossiblePrivileges:@"mportsync" error:sError];
	
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPorts_sync_Finished" object:nil];

	return result;
}

- (void)selfUpdate:(NSError**)sError {
	//Also needs to throw an exception if things don't go well
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPorts_selfupdate_Started" object:nil];
	[[MPNotifications sharedListener] setPerformingTclCommand:@"selfUpdate"];
	
	if([self authorizationMode])
		[interpreter evaluateStringWithMPHelperTool:@"macports::selfupdate" error:sError];
	else
		[interpreter evaluateStringWithPossiblePrivileges:@"macports::selfupdate" error:sError];
	
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MacPorts_selfupdate_Finished" object:nil];
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
	
	NSMutableDictionary *result, *newResult;
	NSEnumerator *enumerator;
	id key;
	NSString *caseSensitivity;
	if (sensitivity) {
		caseSensitivity = @"yes";
	} else {
		caseSensitivity = @"no";
	}

	NSError * sError;
	
	result = [NSMutableDictionary dictionaryWithDictionary:
			  [interpreter dictionaryFromTclListAsString:
			   [interpreter evaluateStringAsString:
				[NSString stringWithFormat:@"return [mportsearch %@ %@ %@ %@]",
				 query, caseSensitivity, style, fieldName] 
											 error:&sError]]];
	
	newResult = [NSMutableDictionary dictionaryWithCapacity:[result count]];
	enumerator = [result keyEnumerator];
	while (key = [enumerator nextObject]) {
		[newResult setObject:[[MPPort alloc] initWithTclListAsString:[result objectForKey:key]] forKey:key];
	}
	

	return [NSDictionary dictionaryWithDictionary:newResult];
}

- (NSArray *)depends:(MPPort *)port {
	return [port depends];
}


- (void)exec:(MPPort *)port 
  withTarget:(NSString *)target 
	 options:(NSArray *)options 
	variants:(NSArray *)variants
	   error:(NSError **)execError
{
	[port exec:target withOptions:options variants:variants error:execError ];
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
		sources = nil;
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
			 [NSString stringWithFormat:@"return [macports::getindex %@ ]", source]
										  error:nil]];
}


- (NSString *)version {
	if (version == nil) {
		
		NSError * vError;
		version = [interpreter evaluateStringAsString:@"return [macports::version]" error:&vError];
	}
	return version;
}

-(void) setAuthorizationMode:(BOOL)mode {
	authorizationMode = mode;
}

-(BOOL) authorizationMode {
	return authorizationMode;
}

#pragma mark -
#pragma mark Delegate Methods

-(id) delegate {
	return macportsDelegate;
}

-(void) setDelegate:(id)aDelegate {
	[aDelegate retain];
	[macportsDelegate release];
	macportsDelegate = aDelegate;
}

//Internal Method for setting our Authorization Reference
- (void) setAuthorizationRef { 
	if ([[self delegate] respondsToSelector:@selector(getAuthorizationRef)]) {
		
		AuthorizationRef clientRef = (AuthorizationRef) [[self delegate] performSelector:@selector(getAuthorizationRef)];
		[interpreter setAuthorizationRef:clientRef];
	}
}

#pragma mark -
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
												 name:MPDEBUG
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPDEFAULT
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
		NSLog(@"MPMacPorts received notification with empty userInfo Dictionary");
	else
		NSLog(@"MPMacPorts received notification with userInfo %@" , [sentDict description]);
}

@end
