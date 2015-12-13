//
//  MPPortProcess.m
//  MacPorts.Framework
//
//  Created by Juan Germán Castañeda Echevarría on 7/9/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "MPPortProcess.h"
#import "SimpleLog.h"

@interface MPPortProcess (PrivateMethods)

- (void)initializeInterpreter;

@end

@implementation MPPortProcess

- (id)initWithPKGPath:(NSString*)pkgPath {
    NSLog(@"Fool");
    PKGPath = pkgPath;
    [self initializeInterpreter];
    return self;
}

- (oneway void)evaluateString:(bycopy id)statement {
    // TODO Handle the posible errors and notifications
    int retCode = Tcl_Eval(interpreter, [statement UTF8String]);
    if (retCode != TCL_OK) {
        Tcl_Obj * interpObj = Tcl_GetObjResult(interpreter);
        int length, errCode;
        NSString * errString = [NSString stringWithUTF8String:Tcl_GetStringFromObj(interpObj, &length)];
        errCode = Tcl_GetErrno();
    
        NSLog(@"- %@ - %i", errString, errCode);
        exit(errCode);
    }
    
    exit(retCode);
}


#pragma mark Private Methods

- (void)initializeInterpreter {
    // Create interpreter
    interpreter = Tcl_CreateInterp();
	if(interpreter == NULL) {
		NSLog(@"Error in Tcl_CreateInterp, aborting.");
	}
    // Initialize interpreter
    if(Tcl_Init(interpreter) == TCL_ERROR) {
		NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
	}
    // Load macports_fastload.tcl from PKGPath/macports1.0
    /*
    NSString * mport_fastload = [[@"source [file join \"" stringByAppendingString:PKGPath]
								 stringByAppendingString:@"\" macports1.0 macports_fastload.tcl]"];
	if(Tcl_Eval(interpreter, [mport_fastload UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile macports_fastload.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
	}*/
    // Load notifications methods
    Tcl_CreateObjCommand(interpreter, "simplelog", SimpleLog_Command, NULL, NULL);
	if (Tcl_PkgProvide(interpreter, "simplelog", "1.0") != TCL_OK) {
		NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(interpreter));
	}
    // Load portProcessInit.tcl
    NSString *portProcessInitPath = @"portProcessInit.tcl";
    if( Tcl_EvalFile(interpreter, [portProcessInitPath UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile portProcessInit.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
	}
}

@end

int main(int argc, char const * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSConnection *portProcessConnection; 
    portProcessConnection = [NSConnection defaultConnection];
    NSString *PKGPath = [[NSString alloc] initWithCString:argv[1] encoding:NSASCIIStringEncoding];
    
    MPPortProcess *portProcess = [[MPPortProcess alloc] initWithPKGPath:PKGPath];
    
    // Vending portProcess
    [portProcessConnection setRootObject:portProcess];
    
    // Register the named connection
    if ( [portProcessConnection registerName:@"MPPortProcess"] ) {
        NSLog( @"Successfully registered connection with port %@", 
              [[portProcessConnection receivePort] description] );
    } else {
        NSLog( @"Name used by %@", 
              [[[NSPortNameServer systemDefaultPortNameServer] portForName:@"MPPortProcess"] description] );
    }
    
    // Wait for any message
    [[NSRunLoop currentRunLoop] run];
  	[pool release];
    return 0;
}