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
 MPReceipt provides a programatic interface to the receipt(s) for installed ports.
 */

#import <Cocoa/Cocoa.h>
#import "MPInterpreter.h"
#import "MPRegistry.h"


/*!
 @class MPReceipt
 @abstract Object representation of an port's receipt
 @discussion A receipt consists mainly of the port's name, version, revision number, variants, whether or not
 it is an active port, and some other information on the port. All receipts on the user's MacPorts system are
 kept in the port registry located in ${prefix}/var/macports/receipts/.
 */

@interface MPReceipt : MPMutableDictionary {

}


/*!
 @brief This method initializes the MPReceipt object with a name, version, revision, variants, active state and long description.
 @param array An NSArray object containing the values for initializing this MPReceipt.
 @discussion 
 The MPReceipt object contains an internal dictionary whose keys are the following strings: name, version, revision, variants,
 active, whatIsThis. The values for these keys are provided by the initializing array parameter.
 */
- (id)initWithContentsOfArray:(NSArray *)array;

+ (Class)classForKeyedUnarchiver;
- (Class)classForKeyedArchiver;

@end
