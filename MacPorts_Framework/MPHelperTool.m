//
//  MPHelperTool.m
//  MacPorts.Framework
//
//  Created by George  Armah on 7/28/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

//#include <netinet/in.h>
#include <stdio.h>
//#include <sys/socket.h>
#include <unistd.h>

#include <CoreServices/CoreServices.h>
#include "BetterAuthorizationSampleLib.h"
#include "MPHelperCommon.h"

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>
#import "MPInterpreter.h"


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
	
	//Pre conditions
	assert(auth != NULL);
	//userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
	//asl may be null
	//aslMsg may be null
	
	//Get the NSString that was passed in the request dictionary
	NSString * tclCmd;
	CFStringRef  cTclCmd = (CFStringRef)CFDictionaryGetValue(request, CFSTR(kTclStringToBeEvaluated));
	
	if (cTclCmd != NULL) {
		tclCmd = (NSString *) cTclCmd;
	}
	else {
		//something went wrong ... do some error handling
		retval = coreFoundationUnknownErr;
	}
	
	MPInterpreter * interp = [MPInterpreter sharedInterpreter];
	NSError * evalError;
	NSString * result = [interp evaluateStringAsString:tclCmd 
												 error:&evalError];
	CFStringRef cResult = (CFStringRef) result;
	
	if( result != nil && evalError != nil) {
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), cResult); 
	}
	else{
		//Try setting the user data pointer to the error
		retval = coreFoundationUnknownErr;
	}
	
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Go directly into BetterAuthorizationSampleLib code.
	
    // IMPORTANT
    // BASHelperToolMain doesn't clean up after itself, so once it returns 
    // we must quit.
    BASHelperToolMain(kMPHelperCommandSet, kMPHelperCommandProcs);
	
	
	[pool release];
	
    return 0;
}


