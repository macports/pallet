/*
 *  SimpleLog.m
 *  MacPorts.Framework
 *
 *  Created by Juan Germán Castañeda Echevarría on 7/21/09.
 *  Copyright 2009 UNAM. All rights reserved.
 *
 */

#include "SimpleLog.h"

@interface NSObject (SimpleLogDelegate) 
-(void)processDidBeginRunning;
-(void)processDidEndRunning;
@end

int Notify_Command(ClientData clientData, Tcl_Interp *interpreter, int objc, Tcl_Obj *CONST objv[]){
    int returnCode = TCL_ERROR;
	
    //NSLog();
    
    if(delegate && [delegate respondsToSelector:@selector(reactToNotification)]) {
        // send messages to delegate
        [delegate processDidBeginRunning];
    }
    
	return returnCode;
}