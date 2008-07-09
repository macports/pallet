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
 The MPInterpreter class allows access to a shared per-thread Tcl interpreter for
 execution of MacPorts commands from upper levels in the API.
 */

#import <Cocoa/Cocoa.h>
#include <tcl.h>

#define	MPPackage			@"macports"
#define MPPackageVersion	@"1.0"

/*!
 @class MPInterpreter
 @abstract Tcl interpreter object
 @discussion Contains a shared per-thread instance of a Tcl interpreter. The MPInterpreter class
 is where the Objective-C API meets the Tcl command line. It is a per-thread interpreter to allow
 users of the API to multi-thread their programs with relative ease.
 */
@interface MPInterpreter : NSObject {

	Tcl_Interp* _interpreter;

}

/*
 @brief Return singleton shared MPInterpreter instance
 */
+ (MPInterpreter *)sharedInterpreter;


#pragma Port Operations

#pragma Port Settings

#pragma Utilities

/*!
 @brief Returns the NSstring result of evaluating a Tcl expression
 @param  statement An NSArray containing the Tcl expression
 @discussion For example, here is the header definition of a MacPorts Tcl API
 call proc macports::getindex {source}. This is how to call this procedure
 in Tcl: [macports::getindex $source]. Calling the macports::getindex
 procedure from Objective-C code with -evaluateArrayAsString however takes the following form:
 
 [SomeMPInterpreterObject evaluateArrayAsString:[NSArray arrayWithObjects:
	@"return [macports::getindex",
	[NSString stringWithString:@"SomeValidMacPortsSourcePath"],
	@"]",
	nil]];
 
 Each element in the array is an NSString. Note the "return" in the first element of the statement
 NSArray.
 */
- (NSString *)evaluateArrayAsString:(NSArray *)statement;
/*!
 @brief Returns the NSString result of evaluating a Tcl expression
 @param  statement An NSString containing the Tcl expression
 @discussion Using the macports::getindex {source} procedure as an example (see discussion for 
 -evaluateArrayAsString), we have the following Objective-C form for calling the macports::getindex
 procedure:
 
 [SomeMPInterpreterObject evaluateStringAsString:
							[NSString stringWithString:@"return [macports::getindex SomeValidMacPortsSourcePath]"]];
 */
- (NSString *)evaluateStringAsString:(NSString *)statement;




/*!
 @brief Returns an NSArray whose elements are the the elements of a Tcl list in the form of an NSString
 @param list A Tcl list in the form of an NSString
 @discussion This method usually takes the result of a call to the evaluateStringAsString and 
 evaluateArrayAsString methods which is a Tcl list and parses it into an NSArray.
 */
- (NSArray *)arrayFromTclListAsString:(NSString *)list;
/*!
 @brief Returns an NSDictionary whose elements are the the elements of a Tcl list in the form of an NSString
 @discussion The returned NSDictionary is of the form {k1, v1, k2, v2, ...} with ki being the keys and vi
 the values in the dictionary. These keys and values are obtained from an NSString Tcl list of the
 form {k1 v1 k2 v2 ...}
 @param list A Tcl list in the form of an NSString
 */
- (NSDictionary *)dictionaryFromTclListAsString:(NSString *)list;
/*!
 @brief Same as dictionaryFromTclListAsString method. Returns an NSMutableDictionary
 rather than NSDictionary.
 */
- (NSMutableDictionary *)mutableDictionaryFromTclListAsString:(NSString *)list;


/*!
 @brief Returns an NSArray whose elements are the contents of a Tcl variable
 @param variable An NSString representation of a Tcl variable
 */
- (NSArray *)getVariableAsArray:(NSString *)variable;
/*!
 @brief Returns an NSString representation of a Tcl variable
 @param variable An NSString representtion of a Tcl variable
 */
- (NSString *)getVariableAsString:(NSString *)variable;



@end
