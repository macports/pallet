//
//  MPHelperTool.m
//  MacPorts.Framework
//
//  Created by George  Armah on 7/28/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "MPInterpreter.h"
#include <stdlib.h>
#include <sys/stat.h>



// /////////////////////////////////////////////////////////////////////////////
// exitCleanly
//
// Exits the program with the correct status and releases the autorelease pool.
void exitCleanly(int code, NSAutoreleasePool *pool)
{
	[pool release];
	exit(code);
}



//This code is adapted from :
// http://forums.macrumors.com/showthread.php?t=508394

//I will first try implementing this without any Authorization services.
//I just want a helper tool whose user id is set to 0 and can self repair itself
//I will be using message passing for IPC rather than piping or anything else
//like that. Check on IRC if there are any dangers in doing that.




//Usage 
// ./MPHelperTool --self-repair srOptions --rec-count recOptions interpCmd
// So argv is of size 6 ... no more no less 

// srOptions is a C string with value of "yes" or "no" to tell us whether or not
// to run self repair

//recOptions is a number telling us how many times we have been called recursively

//interpCmd is a the 

int main(int argc, char const * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	setuid(0);
	NSLog(@"UID is %i", geteuid());	
	//Check for right number of args
	if (argc != 6) {
		exitCleanly(TCL_ERROR , pool);
	}
	
	//The second thing to check for is recOptions ... This method should be called
	//recursively at most once. Its a bit weird but I think from the code above,
	//this tool repairs itself AND THEN proceeds to execute the required command all in
	//one process. This means the number of recursive calls should not exceed one.
	//If we fail to self repair at the first try, we should just exit.

									 
	int recOptions = [[NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding] intValue];
	if (recOptions > 1) {
		exitCleanly(TCL_ERROR, pool);
	}
	else {
		++recOptions;
	}
	
	MPInterpreter * interp = [MPInterpreter sharedInterpreter];
	NSString * interpCmd = [NSString stringWithCString:argv[5] encoding:NSUTF8StringEncoding];
	NSString * _path_to_self = [[NSBundle mainBundle] pathForResource:@"MPHelperTool" 
															   ofType:nil];
	
	//OSStatus status;
	BOOL authenticatedMode = YES;
	//AuthorizationRef auth;
	//AuthorizationExternalForm extAuth;
	
	//This memory pointer should be valid till _path_to_self is freed or released
	//in the autorelease pool .. in other words its save for our purposes
	//and we dont' have to worry about releasing memory
	const char * path_to_self = [_path_to_self cStringUsingEncoding:NSUTF8StringEncoding];
	
	if (!strcmp(argv[1], "--self-repair") && !strcmp(argv[2], "yes") )
	{
		NSLog(@"MacPortsFramework MPHelperTool main Self-repair. Starting");
		// We have started ourself in self-repair mode.  This means that this executable is not owned by root and/or the setuid bit is not set.  We need to recover that...
		struct stat st;
        int fd_tool;
		
		
		//We don't need this code for now
		/* Recover the passed in AuthorizationRef.*/
		
		
		/* Open tool exclusively, so noone can change it while we bless it */
        fd_tool = open(path_to_self, O_NONBLOCK|O_RDONLY|O_EXLOCK, 0);
		
        if (fd_tool == -1)
        {
            NSLog(@"MacPortsFramework MPHelperTool main Self-Repair. Exclusive open while repairing tool failed: %d.",errno);
			exitCleanly(-1,pool);
        }
		
        if (fstat(fd_tool, &st))
		{
			NSLog(@"MacPortsFramework MPHelperTool main Self-Repair. fstat failed");
            exitCleanly(-1,pool);
		}
        
        if (st.st_uid != 0)
		{
            fchown(fd_tool, 0, st.st_gid);
		}
		
		
        /* Disable group and world writability and make setuid root. */
        fchmod(fd_tool, (st.st_mode & (~(S_IWGRP|S_IWOTH))) | S_ISUID);
		
        close(fd_tool);
		
		NSLog(@"MacPortsFramework MPHelperTool main Self-repair. Complete");
		authenticatedMode = YES;
		
		
		/*/Hopefully this works
		int result = [interp execute:_path_to_self 
							withArgs:[NSArray arrayWithObjects:SELF_REPAIR, @"no", REC_COUNT, 
									  [NSString stringWithFormat:@"%d", recOptions], interpCmd,  nil]];
		
		exitCleanly(result, pool);*/
		
		
	}
	else
	{
		//To Do
		//Add code here to receive Authorization reference from somwhere
		
		authenticatedMode = YES;
	}
	
	/* If we are not running as root we need to self-repair. But we don't want to do it more than once
	 which means */
	if (authenticatedMode && geteuid() != 0)
	{
		NSLog(@"MacPortsFramework MPHelperTool main Normal-Mode. Not running as root! Starting self-repair mode.");
		
		//We run again in self repair mode. I am assuming that this new "forked" process
		// will be able to repair the binary and execute the command successfully ... 
		//if it fails I guess i should return something to that effect?
		int result = [interp execute:_path_to_self 
			   withArgs:[NSArray arrayWithObjects:SELF_REPAIR, @"yes", REC_COUNT, 
						 [NSString stringWithFormat:@"%d", recOptions], interpCmd,  nil]];
		
		
		//Is the above method guaranteed to always complete before the
		//program execution gets here?
		exitCleanly(result, pool);
		
		
	}
	
	//Now we can finally execute the method ... whew
	if (interpCmd != nil) {
		NSError * evalError;
		NSLog(@"Executin Tcl command %@", interpCmd);
		
		NSString * result = [interp evaluateStringAsString:interpCmd 
													 error:&evalError];
		if(result == nil && evalError) {
			NSLog(@"Command %@ exited with Error %@", interpCmd, evalError);
			exitCleanly(TCL_ERROR,pool);
		}
		else {
			NSLog(@"Command %@ returned %@", interpCmd, result);
			exitCleanly(TCL_OK, pool);
		}
		/*while(*argv != NULL) {
			NSLog(@"Passed parameter is %@", [NSString stringWithCString:*argv]);
			++argv;
		}*/
	}
	
    [pool release];
	
	
    return 0;
}


