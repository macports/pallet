/*
 *  SimpleLog.m
 *  MacPorts.Framework
 *
 *  Created by Juan Germán Castañeda Echevarría on 7/21/09.
 *  Copyright 2009 UNAM. All rights reserved.
 *
 */

#include "SimpleLog.h"

#define MPSEPARATOR @"_&MP&_"

int SimpleLog_Command(ClientData clientData, Tcl_Interp *interpreter, int objc, Tcl_Obj *CONST objv[]) {
    int tclResult = TCL_ERROR;
	NSMutableString * data;
	
	++objv, --objc;
	
	if (objc) {
		int tclCount;
		const char **tclElements;
		
		tclResult = Tcl_SplitList(interpreter, Tcl_GetString(*objv), &tclCount, &tclElements);
		
		
		if (tclResult == TCL_OK) {
			if (tclCount > 0) {
                NSLog(@"%@", [NSString stringWithUTF8String:tclElements[0]]);
				data = [NSMutableString stringWithUTF8String:tclElements[0]];
				[data appendString:MPSEPARATOR];
				
				if(tclCount > 1 && tclElements[1]) {
                    NSLog(@"%@", [NSString stringWithUTF8String:tclElements[1]]);
					[data appendString:[NSString stringWithUTF8String:tclElements[1]]];
					[data appendString:MPSEPARATOR];
				}
				else {
					[data appendString:@"None"];
					[data appendString:MPSEPARATOR];
				}
				
				if(tclCount > 2 && tclElements[2]) {
                    NSLog(@"%@", [NSString stringWithUTF8String:tclElements[2]]);
					[data appendString:[NSString stringWithUTF8String:tclElements[2]]];
					[data appendString:MPSEPARATOR];
				}
				else {
					[data appendString:@"None"];
					[data appendString:MPSEPARATOR];
				}
			}
			else {
				data = [NSMutableString stringWithFormat:@"None%@None%@None%@", MPSEPARATOR, MPSEPARATOR, MPSEPARATOR ];
			}
		}
	}
    
    //Now get the actual message
    ++objv; --objc;
    if (objc) {
        [data appendString:[NSString stringWithUTF8String:Tcl_GetString(*objv)]];
    }
    else {
        [data appendString:@"None"];
    }
    
    id theProxy = [NSConnection
                   rootProxyForConnectionWithRegisteredName:@"MPNotifications"
                   host:nil];
    [theProxy sendIPCNotification:data];
    
    NSLog(@"-----%@", data);
    
	return tclResult;
}