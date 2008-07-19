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


#import "MPNotifications.h"


@implementation MPNotifications

static MPNotifications *sharedMPListener = nil;



+ (MPNotifications *)sharedListener {
	@synchronized(self) {
		if (sharedMPListener == nil) {
			[[self alloc] init];
		}
	}
	return sharedMPListener;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedMPListener == nil) {
			sharedMPListener = [super allocWithZone:zone];
			return sharedMPListener;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

-(void) release {
	//do nothing
}

- (id) autorelease {
	return self;
}

- (id)init {
	if (self = [super init]) {
		performingTclCommand = @"";
		blockOptions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						[NSNumber numberWithInt:0], MPMSG, [NSNumber numberWithInt:0], MPINFO, 
						[NSNumber numberWithInt:0], MPWARN, [NSNumber numberWithInt:0], MPERROR, 
						[NSNumber numberWithInt:1], MPDEBUG, [NSNumber numberWithInt:0], MPALL, nil];
		NSLog(@"Dictionary is %@ ", [blockOptions description]);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}


- (void) setPerformingTclCommand:(NSString *)tclString {
	
	if(performingTclCommand != tclString){
		[performingTclCommand release];
		performingTclCommand = [tclString copy];
	}
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"testMacPortsNotification" 
	//												   object:self];
}

- (NSString *) performingTclCommand {
	return performingTclCommand;
}

//Should I raise an exception for invalid blockOptions that are
//passed to this method?
-(BOOL)checkIfNotificationBlocked:(NSString *)option {
	if ( [[blockOptions objectForKey:option] intValue] == 1 ) {
		return YES;
	}
	return NO;
}

-(void)blockNotification:(NSString *)option {
	//Should do some checking first
	if ( ! [self checkIfNotificationBlocked:option] ){
		[blockOptions setObject:[NSNumber numberWithInt:1] 
						 forKey:option];
	}	
}

-(void)unblockNotification:(NSString *)option {
	if ( [self checkIfNotificationBlocked:option] ) {
		[blockOptions setObject:[NSNumber numberWithInt:0] 
						 forKey:option];
	}
}


@end
