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

/*!
 @header
 MPRegistry provides a programatic interface to the registry of installed ports.
 The MPRegistry class is a wrapper around the Tcl Registry API. For interacting 
 with all available ports, see the @link MPIndex MPIndex @/link.
 */
#import <Cocoa/Cocoa.h>
#import "MPInterpreter.h"
#import "MPPort.h"
#import "MPReceipt.h"

/*!
 @class MPRegistry
 @abstract The registry of installed ports.
 */
@interface MPRegistry : NSObject {

	MPInterpreter *interpreter;

}

+ (MPRegistry *)sharedRegistry;

/*!
 @brief Calls [self installed:@""]
 */
- (NSDictionary *)installed;

/*
 @brief Calls [self installed:name version:@""]
 @param name Text to match the port name
 */
- (NSDictionary *)installed:(NSString *)name;

/*
 @brief Returns an NSDictionary of MPReciepts keyed by port name
 @param name Text to match the port name
 @param version Text to match the port version
 */
- (NSDictionary *)installed:(NSString *)name withVersion:(NSString *)version;

/*!
 @brief Returns an array of installed port names
 @param name Text to match the port name
 @param version Text to march the port version
 */
- (NSArray *)installedAsArray:(NSString *)name withVersion:(NSString *)version;

/*!
 @brief Returns an array of the files in the (installed and active) port
 */
- (NSArray *)filesForPort:(NSString *)name;

@end
