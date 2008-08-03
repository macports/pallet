/*
 *  MPHelperTool.c
 *  MacPorts.Framework
 *
 *  Created by George  Armah on 8/2/08.
 *  Copyright 2008 Lafayette College. All rights reserved.
 *
 */

//#include <netinet/in.h>
#include <stdio.h>
//#include <sys/socket.h>
#include <unistd.h>

#include <CoreServices/CoreServices.h>

#include "BetterAuthorizationSampleLib.h"

#include "MPHelperCommon.h"

static OSStatus DoEvaluateTclString (
		AuthorizationRef			auth,
		const void *				userData,
		CFDictionaryRef				request,
		CFMutableDictionaryRef		response,
		aslclient					asl,
		aslmsg						aslMsg
)
{
	
	OSStatus		retval = noErr;
	//CFStringRef result;
	//CFAllocatorRef alloc_default = kCFAllocatorDefault; 
	
	//Pre conditions
	assert(auth != NULL);
	//userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
	//asl may be null
	//aslMsg may be null
	
	//Get the string that was passed in the request dictionary
	CFStringRef  cTclCmd = (CFStringRef)CFDictionaryGetValue(request, CFSTR(kTclStringToBeEvaluated));
	//cTclCmd = CFRetain(cTclCmd);
	if (cTclCmd == NULL) {
		retval = coreFoundationUnknownErr;
	}
	
	/*
	//Now retrieve the pointer to the Tcl_Interp that was passed to us
	Tcl_Interp * _userDataInterp = (Tcl_Interp *) userData;
	if(Tcl_Eval(_userDataInterp, CFStringGetCStringPtr(cTclCmd, kCFStringEncodingUTF8)) == TCL_ERROR) {
		//Should do some kind of error handling here
		retval = coreFoundationUnknownErr;
	}
	else {
		result = CFStringCreateWithCString(alloc_default, Tcl_GetStringResult(_userDataInterp), kCFStringEncodingUTF8);
	}
	*/

	
	if( retval == noErr) {
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), cTclCmd); 
	}
	else{
		//Try setting the user data pointer to the error
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), CFSTR("BAAD")); 
	}
	
	assert(response != NULL);
	//I think I should release cTclCmd
	//CFRelease(cTclCmd);
	
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


//Should I just do stuff in main and use the above method to 
//just retrieve the string to be evaluated as a tcl command?

int main(int argc, char const * argv[]) {
	// Go directly into BetterAuthorizationSampleLib code.
	
    // IMPORTANT
    // BASHelperToolMain doesn't clean up after itself, so once it returns 
    // we must quit.
    return BASHelperToolMain(kMPHelperCommandSet, kMPHelperCommandProcs);

}

