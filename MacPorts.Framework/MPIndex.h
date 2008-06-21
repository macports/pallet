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
 The MPIndex maintains an in-memory cache of all available ports and their 
 install status.
*/
#import <Cocoa/Cocoa.h>
#import "MPMacPorts.h"
#import "MPPort.h"

#define MPIndexWillSetIndex	@"org.macports.framework.index.willSetIndex"
#define MPIndexDidSetIndex	@"org.macports.framework.index.didSetIndex"

/*!
 @class MPIndex
 @abstract Index of all ports
 @discussion Maintains an in-memory cache of all available ports and their 
 install status. The MPIndex class is analogous to the PortIndex files for every 
 port collection (most users have just one collection listed in 
 /opt/local/etc/macports/sources.conf).
 */
@interface MPIndex : MPMutableDictionary {

}

/*!
 @brief Initialize a newly allocated index with enough memory for numItems ports
 @param numItems The number of ports that the index will initially have capacity for
 */
- (id)initWithCapacity:(unsigned)numItems;

/*!
 @brief Returns a new array conaining of all available ports
 */
- (NSArray *)ports;

/*!
@brief Returns a new array of all port names
 */
- (NSArray *)portNames;

/*!
@brief Loads all ports into the index from the MacPorts backend
*/
- (void)setIndex;

/*!
@brief Returns the port with the given name
@param name The name of the port
 */
- (MPPort *)port:(NSString *)name;

/*!
@brief Returns an enumerator of all ports
 */
- (NSEnumerator *)portEnumerator;

/*!
 @brief Removes the port with the given name from the index
 @param name The name of the port
 */
- (void)removePort:(NSString *)name;

/*!
@brief Adds the port to the index
@param port The port
@discussion The default state for the port is "not installed"
 */
- (void)setPort:(MPPort *)port;

+ (Class)classForKeyedUnarchiver;
- (Class)classForKeyedArchiver;

@end