/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 * 	George Armah <armahg@macports.org>
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

#import "SharedTextView.h"


@implementation SharedTextView

static SharedTextView *_sharedTextView = nil;

+(SharedTextView*) sharedTextView {
	@synchronized(self) {
		if (_sharedTextView == nil) {
			[[self alloc] init];
		}
	}
	return _sharedTextView;
}

+ (id) allocWithZone:(NSZone *)zone {
	if (_sharedTextView == nil) {
		_sharedTextView = [super allocWithZone:zone];
		return _sharedTextView;
	}
	return nil;
}

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

- (id) retain {
	return self;
}

- (unsigned) retainCount {
	return UINT_MAX;
}

- (void) release {
	//do nothing ... so why does the
	//Apple documentation implement it in the first place?
	//Could it be that they are overriding an original method that
	//did something?
}

- (id) autorelease {
	return self;
}

- (IBAction)clearText:(id)sender {
	[self writeText:@""];
}

- (void)writeText:(NSString *)text {
	[[textView documentView] setString:text];
}

- (void)appendText:(NSString *)text {
	[[textView documentView] insertText:text];
}


@end
