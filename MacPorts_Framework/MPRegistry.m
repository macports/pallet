/*
 *	$Id:$
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

#import "MPRegistry.h"


@implementation MPRegistry

- (id) init {
	if (self = [super init]) {
		interpreter = [MPInterpreter sharedInterpreter];
	}
	return self;
}

+ (MPRegistry *)sharedRegistry {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPRegistry"] == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPRegistry"];
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPRegistry"] == nil) {
			[[[NSThread currentThread] threadDictionary] setObject:[super allocWithZone:zone] forKey:@"sharedMPRegistry"];
			return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPRegistry"];	// assignment and return on first allocation
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

- (NSDictionary *)installed {
	return [self installed:@""];
}

- (NSDictionary *)installed:(NSString *)name {
	return [self installed:name withVersion:@""];
}

- (NSDictionary *)installed:(NSString *)name withVersion:(NSString *)version {
	NSArray *raw;
	MPReceipt *receipt;
	NSMutableDictionary *result;
	NSEnumerator *rawEnumerator;
	NSArray *versions;
	id item;
	raw = [self installedAsArray:name withVersion:version];
	result = [[NSMutableDictionary alloc] initWithCapacity:[raw count]];
	rawEnumerator = [raw objectEnumerator];
	while (item = [rawEnumerator nextObject]) {
		versions = [interpreter arrayFromTclListAsString:item];
		if ([versions count] == 6) {
			receipt = [[MPReceipt alloc] initWithContentsOfArray:versions];
			if ([result objectForKey:[versions objectAtIndex:0]]) {
				[result setObject:[[result objectForKey:[versions objectAtIndex:0]] arrayByAddingObject:receipt] forKey:[versions objectAtIndex:0]];
			} else {
				[result setObject:[NSArray arrayWithObject:receipt] forKey:[versions objectAtIndex:0]];
			}
		}
	}
	return result;
}

- (NSArray *)installedAsArray:(NSString *)name withVersion:(NSString *)version {
	return [interpreter arrayFromTclListAsString:[interpreter evaluateArrayAsString:[NSArray arrayWithObjects:
		@"return [registry::installed",
		name,
		version,
		@"]",
		nil
		]]];
}

- (NSArray *)filesForPort:(NSString *)name {
	return [interpreter arrayFromTclListAsString:[interpreter evaluateArrayAsString:[NSArray arrayWithObjects:
		@"return [registry::port_registered",
		name,
		@"]",
		nil
		]]];
}

@end
