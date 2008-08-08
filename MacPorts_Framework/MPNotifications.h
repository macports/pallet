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

/*!
 @header
 The MPNotifications class aids in handling notifications of port activity that are to be
 sent to Framework clients. The following constants MPMSG, MPINFO, MPWARN, MPERROR, MPDEBUG
 define the names of notifications that Framework clients can register for.
 
 The posted notificaion's userInfo dictionary contains the following keys and values
 MPNOTIFICATION_NAME - The name of the notification e.g. MPWARN, MPDEBUG etc.
 MPCHANNEL - The channel to which the message was logged eg. stdout, stderr
 MPPREFIX - The prefix string for this message e.g. DEBUG:
 MPMETHOD - The method whose execution led to this notification eg. sync, selfupdate
 MPMESSAGE - The output message logged to channel
 
 
 THERE IS A REASON I'M NOT INCLUDING MPALL AS ONE OF THE POSSIBLE NOTIFICATIONS TO REGISTER FOR.
 HOW IS THE FRAMEWORK SUPPOSE TO KNOW THAT SOMEONE HAS REGISTERED FOR ALL NOTIFICATIONS? THE ONLY
 WAY TO DO THAT THAT I CAN SEE IS FORCING CLIENTS TO USE A CUSTOM METHOD (THAT UPDATES SOME
 INTERNAL VARIABLE) OTHER THAN THE COCOA NSNOTIFICATION METHODS FOR REGISTERING ... I DON'T
 WANT TO DO THAT.
 
 SO CLIENTS CAN BOTH REGISTER FOR AND BLOCK CERTAIN NOTIFICATIONS FROM BEING SENT ... IS THIS
 TOO MUCH FLEXIBILITY? WILL THIS GET CONFUSING? IF I WAS A FRAMEWORK USER I WOULD JUST
 REGISTER FOR THE NOTIFICATIONS I'M INTERESTED IN AND NOT CARE ABOUT THE REST. BUT ON THE
 FRAMEWORK SIDE I DON'T WANT TO GO THROUGH OVERHEAD OF SENDING A NOTIFICATION OF THE CLIENT
 IS DEFINITELY NOT GOING TO USE IT ....
 
 OK DISCUSS WITH RANDALL.
 */

#import <Cocoa/Cocoa.h>

#define MPDEFAULT @"MPDefaultNotification"
#define MPMSG @"MPMsgNotification"
#define MPINFO @"MPInfoNotification"
#define MPWARN @"MPWarnNotification"
#define MPERROR @"MPErrorNotification"
#define MPDEBUG @"MPDebugNotification"
#define MPALL @"MPAllNotification"


#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <string.h>


/*!
 @class MPNotifications
 @abstract A class to handle notifying Framework clients of port activity
 @discussion This class aids in sending NSNotifications to Framework clients for various messages
 that would usually be logged to stdout. It also allows for filtering of messages based on
 message priority.
 */

@interface MPNotifications : NSObject {
	NSString * performingTclCommand;
	NSMutableDictionary * blockOptions;
	NSFileHandle * acceptHandle; 
	NSFileHandle * readHandle;
	
	//BSD sockets stuff
	NSString * serverFilePath;
	int sd1, rc;
	struct sockaddr_un serveraddr;
	BOOL hasSetFileDescriptor;
	
}

/*!
 @brief Return singleton shared MPNotifications instance
 @discussion Should I make this per thread as Randall did with MPInterpreter
 and MPMacPorts?
 */
+ (MPNotifications *)sharedListener;

/*!
 @brief Returns YES if notification has been blocked and NO if it has not.
 @param option The priority level of the checked notification. Can be one of MPMSG, MPINFO, MPWARN, MPERROR, MPDEBUG OR MPALL.
 @discussion The above constants for option correspond to msg, info, warn, error, debug
 and all console messages respectively. If calling this function with MPALL
 returns true then all notifications will be blocked. 
 
 SHOULD I ALLOW FOR CUSTOM PRIOTIRITIES?
 */
-(BOOL)checkIfNotificationBlocked:(NSString *)option;

/*!
 @brief Blocks notifications having priority corresponding to option from being sent
 @param option The priority level of the notification to be blocked. Can be one of MPMSG, MPINFO, MPWARN, MPERROR, MPDEBUG OR MPALL.
 @discussion This method does nothing if notification has already been blocked.
 
 SHOULD I RETURN SOME SORT OF VALUE FOR A SUCCESSFUL BLOCKING ... OR OTHERWISE?
 */
-(void)blockNotification:(NSString *)option;

/*!
 @brief Unblocks notifications having priority corresponding to option parameter.
 @param option The priority level of the notification to be unblocked. Can be one of MPMSG, MPINFO, MPWARN, MPERROR, MPDEBUG OR MPALL.
 @discussion This method does nothing if notification has not been already blocked.
 
 SHOULD I RETURN SOME SORT OF VALUE FOR A SUCCESSFUL BLOCKING ... OR OTHERWISE?
 */
-(void)unblockNotification:(NSString *)option;


//These methods aren't for the public ... yet ...
-(void)setPerformingTclCommand:(NSString *)string;
-(NSString *)performingTclCommand;



@end
