/*
 *  MPHelperCommon.h
 *  MacPorts.Framework
 *
 *  Created by George  Armah on 7/31/08.
 *  Copyright 2008 Lafayette College. All rights reserved.
 *
 */

#ifndef _MPHELPERCOMMON_H
#define _MPHELPERCOMMON_H

#include "BetterAuthorizationSampleLib.h"
#include <tcl.h>

#define asl_NSLog(client, msg, level, format, ...) asl_log(client, msg, level, "%s", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#ifndef ASL_KEY_FACILITY
#   define ASL_KEY_FACILITY "Facility"
#endif


//We need only one command for this Tool

#define kMPHelperEvaluateTclCommand					"EvaluateTcl"

	// authorization right name
	
	#define kMPHelperEvaluateTclRightsName			"com.MacPorts.MacPortsFramework.EvaluateTcl"

	// request  keys 
	// Should I put the NSError object in the request dictionary ? 
	// I'll try that for now and see how it goes
	
	//String to be Evlauted
	#define kTclStringToBeEvaluated		"TclString"					//CFString 

	//Tcl MacPorts Package Initialization Path
	#define kTclInterpreterInitPath		"TclInitPath"				//CFString
	
	//Tcl interpInit.tcl Path
	#define kInterpInitFilePath			"InterpInitTclFilePath"		//CFString

	//File Descriptor for server file
	#define kServerFileDescriptor		"ServerFileDescriptor"		//CFNumber

	//File path for IPC socket
	#define kServerFileSocketPath		"ServerFileSocketPath"		//CFString






	//response keys
	#define kTclStringEvaluationResult	"TclStringEvaluationResult"		//CFString

	#define kTclReturnCode				"TclReturnCode"					//CFNumber (TCL_OK, TCL_ERROR etc.)


	//Key for Testing Distributed Object implementation
	#define kMPInterpreterDistObj		"MPInterpreterDistObj"

extern const BASCommandSpec kMPHelperCommandSet[];

#endif