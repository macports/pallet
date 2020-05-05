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

#import "MPIndex.h"


@implementation MPIndex

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setIndex];
	}
	return self;
}

- (id)initWithCapacity:(unsigned)numItems {
	self = [super initWithCapacity:numItems];
	if (self != nil) {
		[self setIndex];
	}
	return self;
}

//- (void)dealloc {
//	[super dealloc];
//}

/*
 * We enumerate the list of ports, adding each port object to our own dictionary instead of simply copying the
 * source dictionary in since we want to explicitely set the port state to uninstalled instead of the default
 * state of unknown.
 *
 * After that we enumerate through the list of installation reciepts and set the port states for in the installed
 * ports as installed, active, or outdated as appropriate
 */
- (void)setIndex {
	NSDictionary *ports;
	NSEnumerator *enumerator;
	id port;
	[[NSNotificationCenter defaultCenter] postNotificationName:MPIndexWillSetIndex object:nil];
	ports = [[MPMacPorts sharedInstance] search:MPPortsAll];
	enumerator = [ports keyEnumerator];
	while (port = [enumerator nextObject]) {
		[self setPort:[ports objectForKey:port]];
	}
	ports = [[MPRegistry sharedRegistry] installed];
	enumerator = [ports keyEnumerator];
	while (port = [enumerator nextObject]) {
		[[self objectForKey:port] setStateFromReceipts:[ports objectForKey:port]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:MPIndexDidSetIndex object:self];
}

- (NSArray *)ports {
	return [self allValues];
}

- (NSArray *)portNames {
	return [self allKeys];
}

- (MPPort *)port:(NSString *)name {
	return [self objectForKey:name];
}

- (NSEnumerator *)portEnumerator {
	return [self objectEnumerator];
}

- (void)removePort:(NSString *)name {
	[self removeObjectForKey:name];
}

- (void)setPort:(MPPort *)port {
	[port setState:MPPortStateNotInstalled];
	[self setObject:port forKey:[port name]];
}

- (Class)classForKeyedArchiver {
	return [MPIndex class];
}

+ (Class)classForKeyedUnarchiver {
	return [MPIndex class];
}

@end
