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

#import "MPReceipt.h"


@implementation MPReceipt

- (id)initWithContentsOfArray:(NSArray *)array {
	self = [super init];
	if (self != nil) {
		[self setDictionary:[NSDictionary dictionaryWithObjects:array 
														forKeys:[NSArray arrayWithObjects:
															@"name",
															@"version",
															@"revision",
															@"variants",
															@"active",
															@"whatIsThis",
															nil]]];
	}
	return self;
}

//- (void) dealloc {
//	[super dealloc];
//}

#pragma MPMutableDictionary Protocal

- (id)objectForKey:(id)aKey {
	if ([aKey isEqualToString:@"contents"] && ![super objectForKey:aKey]) {
		if ([[self objectForKey:@"active"] intValue]) {
			[self setObject:[[MPRegistry sharedRegistry] filesForPort:[self objectForKey:@"name"]] forKey:aKey];
		} else {
			return nil;
		}
	}
	return [super objectForKey:aKey];
}

- (Class)classForKeyedArchiver {
	return [MPReceipt class];
}

+ (Class)classForKeyedUnarchiver {
	return [MPReceipt class];
}

@end
