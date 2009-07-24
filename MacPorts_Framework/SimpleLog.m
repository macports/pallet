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

@interface NSObject (SimpleLogDelegate) 
-(void)processDidBeginRunning;
-(void)processDidEndRunning;
@end

int SimpleLog_Command(ClientData clientData, Tcl_Interp *interpreter, int objc, Tcl_Obj *CONST objv[]){
    int returnCode = TCL_OK;
    
    NSArray *msgType = [[NSString stringWithUTF8String:Tcl_GetString(*(++objv))] componentsSeparatedByString:@" "];
    NSString *msg = [NSString stringWithUTF8String:Tcl_GetString(*(++objv))];
    
    [delegate doSomething];
    
    NSLog(@"%@ : %@",[msgType objectAtIndex:0], msg);
    
	return returnCode;
}