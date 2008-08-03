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

#import	<Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include "BetterAuthorizationSampleLib.h"
#include "MPHelperCommon.h"
#import "MPInterpreterProtocol.h"

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
	
	//Get the string that was passed in the request dictionary
	CFStringRef  cTclCmd = (CFStringRef)CFDictionaryGetValue(request, CFSTR(kTclStringToBeEvaluated));
	//cTclCmd = CFRetain(cTclCmd);
	if (cTclCmd == NULL) {
		retval = coreFoundationUnknownErr;
	}
	
	//Testing Distributed Objects Implementation
	NSString * tclCmd = (NSString *) cTclCmd;
	id distributedMPInterpreterObject = nil;
	NSConnection * mpConn = [NSConnection connectionWithRegisteredName:MP_DOSERVER 
																  host:nil];
	distributedMPInterpreterObject = [mpConn rootProxy];
	
	
	//CFDictionaryAddValue(response, CFSTR("NSConnection stats"), [[NSConnection defaultConnection] statistics]);
	if ( distributedMPInterpreterObject == nil ) {
		CFDictionaryAddValue(response, CFSTR(kMPInterpreterDistObj), CFSTR("NO"));
		retval = coreFoundationUnknownErr;
	}
	else { //We successfully obtained the distObj
		NSLog(@"IN HERE");
		CFDictionaryAddValue(response, CFSTR(kMPInterpreterDistObj), CFSTR("YES"));
		[distributedMPInterpreterObject setProtocolForProxy:@protocol(MPInterpreterProtocol)];
		NSString * result = [distributedMPInterpreterObject
							 evaluateStringFromMPHelperTool:tclCmd];
		
		if (result != nil) { //successful execution
			CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), CFSTR("Port operation Failed not"));
			retval = noErr;
		}
		else {
			CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), CFSTR("Port operation Failed"));
			retval = coreFoundationUnknownErr;
		}
	}
	
	unsigned int numcon = [[NSConnection allConnections] count];
	CFDictionaryAddValue(response, CFSTR("NSConnections"), CFStringCreateWithFormat(kCFAllocatorDefault , NULL, CFSTR("%u"),numcon) );
	
	CFDictionaryAddValue(response, CFSTR("NSConnection Stats"), [[NSConnection defaultConnection] statistics]);
	/*
	if( retval == noErr) {
		
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), cTclCmd); 
	}
	else{
		//Try setting the user data pointer to the error
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), CFSTR("BAAD")); 
	}*/
	
	assert(response != NULL);
	//I think I should release cTclCmd
	//CFRelease(cTclCmd);
	//CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), CFSTR("Port operation Failed not"));
	
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
	[[NSRunLoop currentRunLoop] run];
	// Go directly into BetterAuthorizationSampleLib code.
	
    // IMPORTANT
    // BASHelperToolMain doesn't clean up after itself, so once it returns 
    // we must quit.
    int result = BASHelperToolMain(kMPHelperCommandSet, kMPHelperCommandProcs);

	[pool release];
	
	return result;
}

