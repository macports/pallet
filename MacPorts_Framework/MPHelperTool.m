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
#define MP_DEFAULT_PKG_PATH		@"/Library/Tcl"


#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include "BetterAuthorizationSampleLib.h"
#include <tcl.h>
#include "MPHelperCommon.h"



//According to the docs all I need is
//the file descriptor that MPNotifications
//obtained when creating the server socket
//I'll save that here when retrieving info.
//fromt he request dictionary
int notificationsFileDescriptor;
BOOL hasSetFileDescriptor = NO;


#pragma mark Tcl Commands
int MPHelperTool_Notifications_Command_One 
(
 ClientData clientData, 
 Tcl_Interp *interpreter, 
 int objc, 
 Tcl_Obj *CONST objv[]
) 
{
	NSString * data;
	NSFileHandle * writeHandle;
	int returnCode = TCL_ERROR;
	int err;
	
	//asl logging stuff
	aslmsg logMsg = asl_new(ASL_TYPE_MSG) ;
	assert(logMsg != NULL);
	asl_set(logMsg, ASL_KEY_FACILITY, "com.apple.console");
	asl_set(logMsg, ASL_KEY_SENDER, "MPHelperTool");
	
	aslclient logClient = asl_open(NULL , NULL, ASL_OPT_STDERR);
	assert(logClient != NULL);
	
	if (hasSetFileDescriptor) {
		writeHandle = [[NSFileHandle alloc] initWithFileDescriptor:notificationsFileDescriptor];
	}
	else {
		asl_NSLog(logClient, logMsg, ASL_LEVEL_ERR, @"Attempted to initialize writeHandle");
		asl_NSLog(logClient, logMsg, ASL_LEVEL_ERR, @"without having set notificationsFileDescriptor value");
	}
	
	err = asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"Starting writing to notification socket");
	assert( err == 0);
	
	++objv, --objc;
	
	if (objc) {
		data = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
		
		//TO DO: Don't just send in raw data ... later i'll want to send in nicely
		//formatted string or do some processing so the full notifications dictionary
		//is sent. For now, I just want to get something functional going first
		
		//This is a blocking operation. I don't mind that because I'll be doing lots
		//of heavy lifting on the MPNotifications side to ensure that it only reads
		//when there is no writing activity taking place etc.
		[writeHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
		err = asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"Wrote %@ " , data);
		assert(err == 0);
		
		returnCode = TCL_OK;
	}
	
	asl_close(logClient);
	[writeHandle release];
	return returnCode;
}





int SimpleLog_Command 
(
 ClientData clientData, 
 Tcl_Interp *interpreter, 
 int objc, 
 Tcl_Obj *CONST objv[]
) 
{
	
	//NS writing to file stuff
	NSString * data;
	NSFileHandle * dHandle;
	NSString * destination = @"/Users/Armahg/Desktop/logFile2.txt";
	dHandle = [NSFileHandle fileHandleForWritingAtPath:destination];
	[dHandle truncateFileAtOffset:[dHandle seekToEndOfFile]];
	
	int returnCode = TCL_ERROR;
	int err;
	
	//asl logging stuff
	aslmsg logMsg = asl_new(ASL_TYPE_MSG) ;
	assert(logMsg != NULL);
	asl_set(logMsg, ASL_KEY_FACILITY, "com.apple.console");
	asl_set(logMsg, ASL_KEY_SENDER, "MPHelperTool");
	
	aslclient logClient = asl_open(NULL , NULL, ASL_OPT_STDERR);
	assert(logClient != NULL);
	
	
	err = asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"Starting simplelog Logging");
	assert( err == 0);
	
	++objv, --objc;
	
	if (objc) {
		data = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
		[dHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
		err = asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @" %@ " , data);
		assert(err == 0);
		
		returnCode = TCL_OK;
	}
	
	asl_close(logClient);
	return returnCode;
}



#pragma mark -

static OSStatus DoEvaluateTclString 
(
 AuthorizationRef			auth,
 const void *				userData,
 CFDictionaryRef				request,
 CFMutableDictionaryRef		response,
 aslclient					asl,
 aslmsg						aslMsg
 )
{
	
	OSStatus		retval = noErr;
	
	
	//Pre conditions
	assert(auth != NULL);
	//userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
	//asl may be null
	//aslMsg may be null
	
	//Get the string that was passed in the request dictionary
	NSString *  tclCmd = (NSString *) (CFStringRef)CFDictionaryGetValue(request, CFSTR(kTclStringToBeEvaluated));
	if (tclCmd == nil) {
		retval = coreFoundationUnknownErr;
	}
	
	//Get the tcl Interpreter pkg path
	NSString * tclPkgPath = (NSString *) (CFStringRef) CFDictionaryGetValue(request, CFSTR(kTclInterpreterInitPath));
	if (tclCmd == nil) {
		retval == coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("TclCommandInput"), (CFStringRef)tclCmd);
	
	//Initialize Tcl Interpreter 
	Tcl_Interp * interpreter = Tcl_CreateInterp();
	if(interpreter == NULL) {
		NSLog(@"Error in Tcl_CreateInterp, aborting.");
		
		//For Debugging
		CFDictionaryAddValue(response, CFSTR("TclInterpreterCreate"), CFSTR("NO"));
		retval =  coreFoundationUnknownErr;
	}
	else {//For Debugging
		CFDictionaryAddValue(response, CFSTR("TclInterpreterCreate"), CFSTR("YES"));
	}
	
	if(Tcl_Init(interpreter) == TCL_ERROR) {
		NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("TclInterpreterInit"), CFSTR("NO"));
	}
	else {//For Dbg.
		CFDictionaryAddValue(response, CFSTR("TclInterpreterInit"), CFSTR("YES"));
	}
	
	
	NSString * mport_fastload = [[@"source [file join \"" stringByAppendingString:tclPkgPath]
								 stringByAppendingString:@"\" macports1.0 macports_fastload.tcl]"];
	if(Tcl_Eval(interpreter, [mport_fastload UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile macports_fastload.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("MPFastload"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("MPFastload"), CFSTR("YES"));
	}
	
	//Add simplelog tcl command
	Tcl_CreateObjCommand(interpreter, "simplelog", SimpleLog_Command, NULL, NULL);
	if (Tcl_PkgProvide(interpreter, "simplelog", "1.0") != TCL_OK) {
		NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(interpreter));
		retval = coreFoundationUnknownErr;
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("simplelog"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("simplelog"), CFSTR("YES"));
	}
	
	//Add mphelpertool_notification_one tcl command
	Tcl_CreateObjCommand(interpreter, "mphelpertool_notify1", MPHelperTool_Notifications_Command_One, NULL, NULL);
	if (Tcl_PkgProvide(interpreter, "mphelpertool_notify1", "1.0") != TCL_OK) {
		NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(interpreter));
		retval = coreFoundationUnknownErr;
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("mphnotone"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("mphnotone"), CFSTR("YES"));
	}
	
	
	NSString * interpInitFilePath = (NSString *) (CFStringRef) CFDictionaryGetValue(request, CFSTR(kInterpInitFilePath));
	if (interpInitFilePath == nil) {
		CFDictionaryAddValue(response, CFSTR("interpInitFilePath"), CFSTR("NO"));
		retval = coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("interpInitFilePath"), (CFStringRef)interpInitFilePath);
	
	if( Tcl_EvalFile(interpreter, [interpInitFilePath UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile init.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		CFDictionaryAddValue(response, CFSTR("interpInit.tcl Evaluation"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("interpInit.tcl Evaluation"), CFSTR("YES"));
	}
	
	
	///Evaluate String and set return string value
	NSString * result;
	
	if( Tcl_Eval(interpreter, [tclCmd UTF8String]) == TCL_ERROR ) {
		//Do some error handling
		retval = coreFoundationUnknownErr;
		result = [@"TCL COMMAND EXECUTION FAILED BOO!:" 
				  stringByAppendingString:[NSString stringWithUTF8String:Tcl_GetStringResult(interpreter)]];
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), (CFStringRef)result);
	}
	else {
		retval = noErr;
		result = [@"TCL COMMAND EXECUTION SUCCEEDED YAAY!:" 
				  stringByAppendingString:[NSString stringWithUTF8String:Tcl_GetStringResult(interpreter)]];
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), (CFStringRef)result);
	}
	
	
	assert(response != NULL);
	
	
	return retval;
}

/////////////////////////////////////////////////////////////////
#pragma mark ***** Tool Infrastructure

/*
 IMPORTANT
 ---------
 This array must be exactly parallel to the kMPHelperCommandSet array 
 in "MPHelperCommon.c".
 */

static const BASCommandProc kMPHelperCommandProcs[] = {
DoEvaluateTclString,	
NULL
};

int main(int argc, char const * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int result = BASHelperToolMain(kMPHelperCommandSet, kMPHelperCommandProcs);
	
	[pool release];
	
	return result;
}