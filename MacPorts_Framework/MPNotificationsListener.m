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


#import "MPNotificationsListener.h"


@implementation MPNotificationsListener

static MPNotificationsListener *sharedMPListener = nil;
static NSString *infoString;

+ (MPNotificationsListener *)sharedListener {
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
		//[self registerForLocalNotification];
		//[self registerForGlobalNotification];
		//[self observeInfoString];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void) setInfoString:(NSString *) string {
	infoString = [NSString stringWithString:string];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"testMacPortsNotification" 
													   object:self];
	//NSLog(@"infoString has been set to %@", infoString);
}

- (NSString *) infoString {
	return infoString;
}

/*
-(void) observeInfoString {
	[self addObserver:self 
		   forKeyPath:@"infoString" 
			  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
			  context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context {
	
	if ([keyPath isEqual:@"infoString"]) {
			NSLog(@"InfoString changed from \n \
				  %@ \n \
				  to \n \
				  %@ ", [change objectForKey:NSKeyValueChangeOldKey] ,
				  [change objectForKey:NSKeyValueChangeNewKey]);
	}
	else 
		NSLog (@"HOW DID INFOSTRING CHANGE WITHOUT CHANGING AN INFOSTRING?!");
	
	//There's no super implementation AFAIK
}


-(void) registerForLocalNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:@"testMacPortsNotification"
											   object:nil];
}

-(void) registerForGlobalNotification {
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self 
														selector:@selector(respondToGlobalNotification:) 
															name:@"testMacPortsNotification" 
														  object:nil];
}

-(void) respondToLocalNotification:(NSNotification *)notification {
	id sentObject = [notification object];
	
	//Just NSLog it for now
	if(sentObject == nil)
		NSLog(@"%@", LOCAL_MESSAGE);
	else
		NSLog(@"%@" , NSStringFromClass([sentObject class]));
}

-(void) respondToGlobalNotification:(NSNotification *)notification {
	id sentObject = [notification object];
	
	//Just NSLog it for now
	if(sentObject == nil)
		NSLog(@"%@", GLOBAL_MESSAGE);
	else
		NSLog(@"%@", NSStringFromClass([sentObject class]));
}
*/
@end
