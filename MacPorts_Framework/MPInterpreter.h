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
 execution of MacPorts commands from upper levels in the API. This class is intended
 for internal use. Framework users should not have to interact with it directly in
 order to perform port operations.
 */

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>
#include <tcl.h>  
#import "MPNotifications.h"


//Defining some flags for MPHelperTool
#define MP_HELPER @"MPHelperTool"

#define	MPPackage				@"macports"
#define MPPackageVersion		@"1.0"
#define TCL_RETURN_CODE			@"return code"
#define TCL_RETURN_STRING		@"return string"
#define MPFrameworkErrorDomain	@"MacPortsFrameworkErrorDomain"


#define MPNOTIFICATION_NAME @"Notification"
#define MPCHANNEL  @"Channel"
#define MPPREFIX  @"Prefix"
#define MPMETHOD @"Method"
#define MPMESSAGE @"Message"

//Error codes for helper Tool
#define MPHELPINSTFAILED	0  /*Installation of helper tool failed*/
#define MPHELPUSERCANCELLED 1 /*User cancelled privileged operation.*/


#pragma mark MacPort Options
#define MPVERBOSE				@"ports_verbose"
#define MPDEBUGOPTION			@"ports_debug"
#define MPQUIET					@"ports_quiet"
#define MPPROCESSALL			@"ports_processall"
#define MPEXIT					@"ports_exit"
#define MPFORCE					@"ports_force"
#define MPIGNOREOLDER			@"ports_ignore_older"
#define MPNODEPS				@"ports_nodeps"
#define MPDODEPS				@"ports_do_dependents"
#define MPSOURCEONLY			@"ports_source_only"
#define MPBINARYONLY			@"ports_binary_only"
#define MPAUTOCLEAN				@"ports_autoclean"
#define MPTRACE					@"ports_trace"


/*!
 @class MPInterpreter
 @abstract Tcl interpreter object
 @discussion Contains a shared per-thread instance of a Tcl interpreter. The MPInterpreter class
 is where the Objective-C API meets the Tcl command line. It is a per-thread interpreter to allow
 users of the API to multi-thread their programs with relative ease.
 */
@interface MPInterpreter : NSObject  {
	
	Tcl_Interp*	_interpreter;
	NSString *	helperToolInterpCommand;
	NSString *	helperToolCommandResult;
	NSArray *	defaultPortOptions;
	
}

+(NSString*) PKGPath;

+(void) setPKGPath:(NSString*)newPath;


//Internal methods
-(BOOL) setOptionsForNewTclPort:(NSArray *)options;

-(BOOL) resetTclInterpreterWithPath:(NSString *)path;

/*!
 @brief Return singleton shared MPInterpreter instance
 */
+ (MPInterpreter *)sharedInterpreter;




/*!
 @brief Return singleton shared MPInterpreter instance for specified macports tcl package path
 @param path An NSString specifying the absolute path for the macports tcl package
 */
+ (MPInterpreter *)sharedInterpreterWithPkgPath:(NSString *)path portOptions:(NSArray *)options;



#pragma Port Operations

#pragma Port Settings

#pragma Utilities


/*!
 @brief Returns the NSString result of evaluating a Tcl expression
 @param  statement An NSString containing the Tcl expression
 @param	 mportError A reference pointer to the NSError object which will be used for error handling; should not be nil.
 @discussion Using the macports::getindex {source} procedure as an example we 
 have the following Objective-C form for calling the macports::getindex procedure:
 
 [SomeMPInterpreterObject evaluateStringAsString:
 [NSString stringWithString:@"return [macports::getindex SomeValidMacPortsSourcePath]"]];
 */
- (NSString *)evaluateStringAsString:(NSString *)statement error:(NSError **)mportError;

/*!
 @brief Returns the NSString result of evaluating a Tcl expression executed as root if necessary
 @param  statement An NSString containing the Tcl expression
 @param	 mportError A reference pointer to the NSError object which will be used for error handling; should not be nil.
 @discussion This method is almost identical to -evaluateStringAsString. The only difference is that
 it re-evaluates the Tcl expression with root privileges if the first attempt at evaluation
 returns an error due to insufficient privileges. The -sync, -selfupdate and port exec methods
 use this method for their operations.
 
 [SomeMPInterpreterObject evaluateStringAsString:
 [NSString stringWithString:@"return [macports::mportselfupdate]"]];
 */
- (NSString *)evaluateStringWithPossiblePrivileges:(NSString *)statement error:(NSError **)mportError;



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


// METHODS FOR INTERNAL USE ONLY
- (Tcl_Interp *) sharedInternalTclInterpreter;
- (int) execute:(NSString *)pathToExecutable withArgs:(NSArray*)args;
- (void)setAuthorizationRef:(AuthorizationRef)authRef;
- (BOOL)checkIfAuthorized;
-(NSString *)evaluateStringWithMPHelperTool:(NSString *)statement error:(NSError **)mportError;
-(NSString *)evaluateStringWithMPPortProcess:(NSString *)statement error:(NSError **)mportError;

@end
