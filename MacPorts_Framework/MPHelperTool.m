//
//  MPHelperTool.m
//  MacPorts.Framework
//
//  Created by George  Armah on 7/28/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "MPInterpreter.h"



int main(int argc, char * const *argv) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString * pathtoself = [[NSBundle mainBundle] pathForResource:@"MPHelperTool"
															ofType:nil];
	
	NSLog(@"Path to executable is %@", pathtoself);
	
	if (argc == 2) {
		MPInterpreter * interp = [MPInterpreter sharedInterpreter];
		NSError * evalError;
		++argv;
		NSString * interpCmd = [NSString stringWithCString:*argv];
		NSLog(@"Executin Tcl command %@", interpCmd);
		
		NSString * result = [interp evaluateStringAsString:interpCmd 
													 error:&evalError];
		if(result == nil && evalError) {
			NSLog(@"Command %@ exited with Error %@", interpCmd, evalError);
			return TCL_ERROR;
		}
		else {
			NSLog(@"Command %@ returned %@", interpCmd, result);
			return TCL_OK;
		}
		/*while(*argv != NULL) {
			NSLog(@"Passed parameter is %@", [NSString stringWithCString:*argv]);
			++argv;
		}*/
	}
	
    [pool release];
	
	
    return 0;
}


