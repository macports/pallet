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

@interface MPNotifications (Private)
-(void) socketConnected:(NSNotification *)notification;
-(void) readData:(NSNotification *)notification;
-(void) notifyWithData:(NSNotification *)notification;
-(BOOL) initBSDSocket;
@end



@implementation MPNotifications

+ (MPNotifications *)sharedListener {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPListener"] == nil) {
			[[self alloc] init];
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPListener"];
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPListener"] == nil) {
			[[[NSThread currentThread] threadDictionary] setObject:[super allocWithZone:zone] forKey:@"sharedMPListener"];
			return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPListener"];
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
						[NSNumber numberWithInt:0], MPDEBUG, [NSNumber numberWithInt:0], MPALL, nil];
		//NSLog(@"Dictionary is %@ ", [blockOptions description]);
		
		hasSetFileDescriptor = NO;
		
		if ([self initBSDSocket]) {
			//should I be using the closeDealloc version instead? 
			acceptHandle = [[NSFileHandle alloc] initWithFileDescriptor:sd1];
			readHandle = [[NSFileHandle alloc] initWithFileDescriptor:sd1];
			
	
			
			//It would be nice if I could somehow add the fileHandle in the HelperTool as the sender
			//this notification. That way I don't read stuff not intended for me.
			//Perhaps I should post a distributed notification to indicate initiation of
			//the asynchronous notification?
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(socketConnected:)
														 name:NSFileHandleConnectionAcceptedNotification 
													   object:nil];
			
			//Posts the notification above after accepting a connection
			[acceptHandle acceptConnectionInBackgroundAndNotify];
		}
		
		
	}
	return self;
}

//Internal methods for IPC with helper tool
//This method should really run in a background separate
//thread so that it doesn't black ... I'll implement
//that after I get the basic functionality working
- (void) socketConnected:(NSNotification *) notification {
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(readData:) 
												 name:NSFileHandleDataAvailableNotification 
											   object:nil];
	
	//Need to call this again since it is done only once in init
	//and this is a singleton instance class
	//acceptHandle posts the above notification
	[acceptHandle acceptConnectionInBackgroundAndNotify];
	
	
}

- (void) readData:(NSNotification *) notification {
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithData:) 
												 name:NSFileHandleReadCompletionNotification
											   object:nil];
	
	//Once data is availabl we can call this method
	//it posts the above notification on completion
	[readHandle readInBackgroundAndNotify];
}

- (void) notifyWithData:(NSNotification *) notification {
	NSData * inData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	NSString * inString = [[NSString alloc] initWithData:inData 
												encoding:NSUTF8StringEncoding];
	//Just Log it for now
	NSLog(@"Read in %@ from MPHelperTool", inString);
	[inString release];
	
	//Once we have finished reading a stream of data and we are
	//done logging ... we can start 
	//[acceptHandle acceptConnectionInBackgroundAndNotify];
}

-(BOOL) initBSDSocket {
	//BSD Socket Initialization (maybe I should put this in another method ?)
	sd1 = -1;
	serverFilePath = [[NSBundle bundleForClass:[MPNotifications class]]
					  pathForResource:@"HelperToolServerFile" ofType:@"txt"];
	sd1 = socket(AF_UNIX, SOCK_STREAM, 0);
	if (sd1 < 0) {
		NSLog(@"socket() failed");
	}
	
	memset( &serveraddr, 0, sizeof(serveraddr));
	serveraddr.sun_family = AF_UNIX;
	strcpy(serveraddr.sun_path, [serverFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
	
	rc = bind(sd1, (struct sockaddr *)&serveraddr, SUN_LEN(&serveraddr));
	if (rc < 0) {
		NSLog(@"bind() failed");
	}
	else {
		hasSetFileDescriptor = YES;
	}
	return hasSetFileDescriptor;
}


-(int) getServerFileDescriptor {
	return sd1;
}



- (void)dealloc {
	[super dealloc];
}


- (void) setPerformingTclCommand:(NSString *)tclString {
	
	if(performingTclCommand != tclString){
		[performingTclCommand release];
		performingTclCommand = [tclString copy];
	}
	
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
