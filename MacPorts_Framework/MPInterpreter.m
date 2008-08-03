/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 * 	Randall H. Wood <rhwood@macports.org>
 *
 *	Copyright (c) 2007 Randall H. Wood <rhwood@macports.org>
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions
 *	are met:
 *	1.	Redistributions of source code must retain the above copyright
 *		notice, this list of conditions and the following disclaimer.
 *	2.	Redistributions in binary form must reproduce the above copyright
 *		notice, this list of conditions and the following disclaimer in the
 *		documentation and/or other materials provided with the distribution.
 *	3.	Neither the name of the copyright owner nor the names of contributors
 *		may be used to endorse or promote products derived from this software
 *		without specific prior written permission.
 * 
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 *	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *	POSSIBILITY OF SUCH DAMAGE.
 */

#import "MPInterpreter.h"
#include "BetterAuthorizationSampleLib.h"
#include "MPHelperCommon.h"


/////////////////////////////////////////////////////////////////
#pragma mark ***** Globals

static AuthorizationRef mpAuth;

#pragma mark -

@implementation MPInterpreter

#pragma mark Notifications Code 
int Notifications_Send(int objc, Tcl_Obj *CONST objv[], int global, Tcl_Interp *interpreter) {

	NSString *name;
	NSMutableString *msg;
	NSMutableDictionary *info = nil;
	MPNotifications *mln = [MPNotifications sharedListener];
	
	int tclCount;
	int tclResult;
	int i;
	const char **tclElements;
	
	name = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
	
	//Name and Notification constants should match. Convention
	//used is MPPriorityNotification. Is it ok to just return TCL_OK ?
	if( [mln checkIfNotificationBlocked:name] ){
		return TCL_OK;
	}
	
	
	++objv; --objc;
	
	tclResult = Tcl_SplitList(interpreter, Tcl_GetString(*objv), &tclCount, &tclElements);
	if (tclResult == TCL_OK) {
		info = [NSMutableDictionary dictionaryWithCapacity:(tclCount / 2)];
		for (i = 0; i < tclCount; i +=2) {
			[info setObject:[NSString stringWithUTF8String:tclElements[i + 1]] forKey:[NSString stringWithUTF8String:tclElements[i]]];
		}
		
		//Get ui_* message separately 
		++objv; --objc;
		if(objv != NULL) {
			msg = [NSMutableString stringWithUTF8String:Tcl_GetString(*objv)];
			
			//strip off "--->" over here
			NSArray * temp = [msg componentsSeparatedByString:@"--->"];
			[msg setString:[temp componentsJoinedByString:@""]];
			[info setObject:msg forKey:@"Message"];
		}
		
		//Get the Tcl function that called this method
		if (! [[mln performingTclCommand] isEqualToString:@""]) {
			NSArray * cmd = [[mln performingTclCommand] componentsSeparatedByString:@"_"];
			
			//if code is working right, this value should always be YES
			//when we are in this part of the code
			if([cmd count] > 0) {
				NSLog(@"Class type is %@", NSStringFromClass([[cmd objectAtIndex:0] class]));
				
				if( [[cmd objectAtIndex:0] isEqualToString:@"YES"]) {
					[info setObject:[cmd objectAtIndex:1] forKey:@"Function"];
				}
			}
		}		
		if (global != 0) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:info];
		}
		
		
	} else {
		return TCL_ERROR;
	}
	
	return TCL_OK;
}

int Notifications_Command(ClientData clientData, Tcl_Interp *interpreter, int objc, Tcl_Obj *CONST objv[]) {
	MPNotifications * mln = [MPNotifications sharedListener]; 
	
	//Should I do the filtering in Notificaitons_Send instead?
	if( [mln checkIfNotificationBlocked:MPALL] ) {
		NSLog(@"ALL NOTIFICATIONS BLOCKED");
		return TCL_OK;
	}
	
	NSString *action = nil;
	int returnCode = TCL_ERROR;
	
	++objv, --objc;
	
	if (objc) {
		action = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
		++objv, --objc;
		if ([action isEqualToString:@"send"]) {
			if ([[NSString stringWithUTF8String:Tcl_GetString(*objv)] isEqualToString:@"global"]) {
				++objv, --objc;
				returnCode = Notifications_Send(objc, objv, 1, interpreter);				
			} else {
				returnCode = Notifications_Send(objc, objv, 0, interpreter);
			}
		}
	}
	
	return returnCode;
}

#pragma mark -
#pragma mark Authorization Code
//Internal method for setting up Authorizatin Reference
//Called during initialization of interpreter object
//This is a bit weird: Since MPInterpreter is compiled twice First for the helper
//tool and then for the Framework, we want to call this method only when it is
//being compiled for the Framework ... hence we check that the main bundle name is
//MacPorts.Framework before initializing authorization
-(void) initializeAuthorization {
	//I'll probably regret doing this later on
	//but whatever .... 
	char * username = "armahg";
	char * password = "200485";
	
	OSStatus junk;
	
	//Create Environment specific to this machine for tesitng purposes
	AuthorizationItem envItems[2];
	envItems[0].name = kAuthorizationEnvironmentPassword;
	envItems[0].value = password;
	envItems[0].valueLength = strlen(password);
	envItems[0].flags = 0;
	
	envItems[1].name = kAuthorizationEnvironmentUsername;
	envItems[1].value = username;
	envItems[1].valueLength = strlen(username);
	envItems[1].flags = 0;
	
	AuthorizationItemSet env = { 2 , envItems };
	
	AuthorizationFlags envFlags;
	envFlags = kAuthorizationFlagDefaults |
				kAuthorizationFlagExtendRights |
				kAuthorizationFlagPreAuthorize;
	
	
	junk = AuthorizationCreate(NULL, &env, envFlags, &mpAuth);
	assert(junk == noErr);
	//assert (junk == noErr) == (mpAuth != NULL);
	
	NSString * bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	
	//Set _userDataInterp over here
	//kMPHelperCommandSet[0].userData =  _interpreter;
	
	BASSetDefaultRules(mpAuth, 
					   kMPHelperCommandSet, 
					   (CFStringRef) bundleID, 
					   NULL);
	
}


#pragma mark -

#pragma mark MPInterpreterProtocol

- (BOOL) vendSelfForServer {
	NSConnection * defaultConn;
	defaultConn = [NSConnection defaultConnection];
	NSLog(@"Creating connection ...");
	
	[defaultConn setRootObject:self];
	
	NSLog(@"Connection Created ... %@, %@", defaultConn, [defaultConn statistics]);
	return [defaultConn registerName:MP_DOSERVER];
	
}

- (bycopy NSString *) evaluateStringFromMPHelperTool:(in bycopy NSString *)statement {
//- (NSString *) evaluateStringFromMPHelperTool:(NSString *)statement {	
											//TO DO ->  error:(inout NSError **)evalError {
	//NSError * evalError;
	NSString * result = [self evaluateStringAsString:statement error:nil];
	
	//TO DO : WORK ON ERROR STUFF AFTER GETTING BASIC FUNCTIONALITY WORKING
	//For now ... Perhaps I might now have to take jberry's advice on ... Oh wait
	//I should be able to pass by reference duh!
	//return @"returning from evaluateStringFromMPHelperTool";
	return result;
}

#pragma mark -

#pragma mark MPInterpreter Code

- (id) init {
	return [self initWithPkgPath:MP_DEFAULT_PKG_PATH];
}


- (id) initWithPkgPath:(NSString *)path {
	if (self = [super init]) {
		_interpreter = Tcl_CreateInterp();
		if(_interpreter == NULL) {
			NSLog(@"Error in Tcl_CreateInterp, aborting.");
		}
		if(Tcl_Init(_interpreter) == TCL_ERROR) {
			NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
		
		NSString * mport_fastload = [[@"source [file join \"" stringByAppendingString:path]
									 stringByAppendingString:@"\" macports1.0 macports_fastload.tcl]"];
		if(Tcl_Eval(_interpreter, [mport_fastload UTF8String]) != TCL_OK) {
			NSLog(@"Error in Tcl_EvalFile macports_fastload.tcl: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
		
		Tcl_CreateObjCommand(_interpreter, "notifications", Notifications_Command, NULL, NULL);
		if (Tcl_PkgProvide(_interpreter, "notifications", "1.0") != TCL_OK) {
			NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
		/*if( Tcl_EvalFile(_interpreter, [[[NSBundle bundleWithIdentifier:@"org.macports.frameworks.macports"] pathForResource:@"init" ofType:@"tcl"] UTF8String]) != TCL_OK) {
			NSLog(@"Error in Tcl_EvalFile init.tcl: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}*/
		
		if( Tcl_EvalFile(_interpreter, [[[NSBundle bundleWithIdentifier:@"org.macports.frameworks.macports"] 
										 pathForResource:@"init" 
										 ofType:@"tcl"] UTF8String]) != TCL_OK) {
			NSLog(@"Error in Tcl_EvalFile init.tcl: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
		//Initialize helperToolInterpCommand
		helperToolInterpCommand = @"";
		
		//Initialize the Run Loop because we don't know if framework will be
		//run in a Foundation Kit or App Kit. Hopefully this won't hurt if the
		//run loop is already running. We are doing this so that our NSConnection
		//object is able to handle Distributed Object messages
		//NOTE: Since MPinterpreter instances are created per thread, we don't have to
		//worry (I hope) about running loops for different threads
		//[[NSRunLoop currentRunLoop] run];
		
		if (![self vendSelfForServer]) {
			NSLog(@"Failed To initialize NSConnection server ");
			//Should probably do some more error handling over here
		}
		else
			NSLog(@"MPInterpreter Initialized ...");
			
		
	}
	return self;
}

- (Tcl_Interp *) sharedTclInterpreter {
	return _interpreter;
}


+ (MPInterpreter*)sharedInterpreter {
	return [self sharedInterpreterWithPkgPath:MP_DEFAULT_PKG_PATH];
}

+ (MPInterpreter*)sharedInterpreterWithPkgPath:(NSString *)path {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"] == nil) {
			[[self alloc] initWithPkgPath:path]; // assignment not done here
		}
	}
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"];
}


+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"] == nil) {
			[[[NSThread currentThread] threadDictionary] setObject:[super allocWithZone:zone] forKey:@"sharedMPInterpreter"];
			return [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"];	// assignment and return on first allocation
		}
	}
	return nil;	// subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
	
}

- (id)autorelease {
    return self;
}

#pragma Port Operations

#pragma Port Settings

#pragma Utilities

- (int) execute:(NSString *)pathToExecutable withArgs:(NSArray *)args {
	NSTask * task = [[NSTask alloc] init];
	[task setLaunchPath:pathToExecutable];
	[task setArguments:args];
	[task launch];
	[task waitUntilExit];
	int status = [task terminationStatus];
	[task release];
	return status;
}

/*- (NSDictionary *)evaluateArrayAsString:(NSArray *)statement {
	return [self evaluateStringAsString:[statement componentsJoinedByString:@" "]];
}

*/
- (NSString *)evaluateStringAsString:(NSString *)statement error:(NSError**)mportError{
	NSLog(@"Calling evaluateStringAsString with argument %@", statement);
	
	int return_code = Tcl_Eval(_interpreter, [statement UTF8String]);
	
	//Should I check for (return_code != TCL_Ok && return_code != TCL_RETURN) instead ?
	if (return_code == TCL_ERROR) {
		
		Tcl_Obj * interpObj = Tcl_GetObjResult(_interpreter);
		int length, errCode;
		NSString * errString = [NSString stringWithUTF8String:Tcl_GetStringFromObj(interpObj, &length)];
		//NSLog(@"TclObj string is %@ with length %d", errString , length);
		errCode = Tcl_GetErrno();
		//NSLog(@"Errno Id is %@ with value %d", [NSString stringWithUTF8String:Tcl_ErrnoId()], errCode);
		//NSLog(@"Errno Msg is %@", [NSString stringWithUTF8String:Tcl_ErrnoMsg(errCode)]);
		
		//Handle errors here ... Framework users can do !mportError to find out if
		//method was successful
		NSString *descrip = NSLocalizedString(errString, @"");
		NSDictionary *errDict;
		//For now all error codes are TCL_ERROR
		
		//Create underlying error - For now I'll create the underlying Posix Error
		NSError *undError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain
														code:errCode 
													userInfo:nil] autorelease];
		//Create and return custom domain error
		NSArray *objArray = [NSArray arrayWithObjects:descrip, undError, nil];
		NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
							 NSUnderlyingErrorKey, nil];
		errDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
		if (mportError != NULL)
			*mportError = [[[NSError alloc] initWithDomain:MPFrameworkErrorDomain 
													  code:TCL_ERROR 
												  userInfo:errDict] autorelease];
		return nil;
	}
	
	return [NSString stringWithUTF8String:Tcl_GetStringResult(_interpreter)];
}


/*
- (NSDictionary *)evaluateStringAsString:(NSString *)statement {
	int return_code = Tcl_Eval(_interpreter, [statement UTF8String]);
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:return_code], TCL_RETURN_CODE, 
			[NSString stringWithUTF8String:Tcl_GetStringResult(_interpreter)], TCL_RETURN_STRING, nil];
}
*/

- (NSArray *)arrayFromTclListAsString:(NSString *)list {
	NSMutableArray *array;
	int tclCount;
	int tclResult;
	int i;
	const char **tclElements;
	tclResult = Tcl_SplitList(_interpreter, [list UTF8String], &tclCount, &tclElements);
	if (tclResult == TCL_OK) {
		array = [[NSMutableArray alloc] initWithCapacity:tclCount];
		for (i = 0; i < tclCount; i++) {
			[array addObject:[NSString stringWithUTF8String:tclElements[i]]];
		}
	} else {
		array = [[NSMutableArray alloc] init];
	}
	Tcl_Free((char *)tclElements);
	return [NSArray arrayWithArray:array];
}

- (NSDictionary *)dictionaryFromTclListAsString:(NSString *)list {
	return [NSDictionary dictionaryWithDictionary:[self  mutableDictionaryFromTclListAsString:list]];
}

- (NSMutableDictionary *)mutableDictionaryFromTclListAsString:(NSString *)list {
	NSMutableDictionary *dictionary;
	NSArray *array;
	int i;
	array = [self arrayFromTclListAsString:list];
	dictionary = [[NSMutableDictionary alloc] initWithCapacity:[array count]];
	for (i = 0; i < [array count]; i += 2) {
		[dictionary setObject:[array objectAtIndex:(i + 1)] forKey:[array objectAtIndex:i]];
	}
	return dictionary;
}

- (NSArray *)getVariableAsArray:(NSString *)variable {
	return [self arrayFromTclListAsString:[NSString stringWithUTF8String:Tcl_GetVar(_interpreter, [variable UTF8String], TCL_LIST_ELEMENT)]];
}

- (NSString *)getVariableAsString:(NSString *)variable {
	return [NSString stringWithUTF8String:Tcl_GetVar(_interpreter, [variable UTF8String], 0)];
}

- (NSString *) evaluateStringWithMPHelperTool:(NSString *) statement {
	OSStatus        err;
    BASFailCode     failCode;
    NSString *      bundleID;
    NSDictionary *  request;
    CFDictionaryRef response;
	
	response = NULL;
	
	request = [NSDictionary dictionaryWithObjectsAndKeys:
			   @kMPHelperEvaluateTclCommand, @kBASCommandKey,
			   statement, @kTclStringToBeEvaluated, nil];
	assert(request != NULL);
	
	bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];

	assert(bundleID != NULL);
	
	
	//_userDataInterp points to _interpreter after the
	//method below
	[self initializeAuthorization];
	
	NSLog(@"BEFORE Tool Execution request is %@ , resonse is %@ \n\n", request, response);
	err = BASExecuteRequestInHelperTool(mpAuth, 
										kMPHelperCommandSet, 
										(CFStringRef) bundleID, 
										(CFDictionaryRef) request, 
										&response);
	
	
	//Try to recover
	if ( (err != noErr) && (err != userCanceledErr) ) {
		failCode = BASDiagnoseFailure(mpAuth, (CFStringRef) bundleID);
		
		err = BASFixFailure(mpAuth, 
							(CFStringRef) bundleID, 
							CFSTR("MPHelperInstallTool"), 
							CFSTR("MPHelperTool"), 
							failCode);
		
		if (err == noErr) {
			err = BASExecuteRequestInHelperTool(mpAuth, 
												kMPHelperCommandSet, 
												(CFStringRef) bundleID, 
												(CFDictionaryRef) request, 
												&response);
		}
	}
	else {
		err = userCanceledErr;
	}
	
	assert(response != NULL);
	CFStringRef newresult = CFDictionaryGetValue(response, CFSTR(kTclStringEvaluationResult));
	
	NSLog(@"AFTER Tool Execution request is %@ , resonse is %@ \n\n", request, response);
	//NSLog(@"response dictionary is %@", response);
	return (NSString *) newresult;
	
	
	/*
	NSString * fakeResult = @"Frustrated";
	return fakeResult;

	//Read from file and see if it was written to
	NSString * testFilePath = [[NSBundle bundleForClass:[self class]]
							   pathForResource:@"TestFile" ofType:@"test"];
	NSError * readError = nil;
	NSString * result = [NSString stringWithContentsOfFile:testFilePath 
												  encoding:NSUTF8StringEncoding
													 error:&readError];
	if (readError) {
		NSLog(@"Error is %@", [readError description]);
		return @"There was an error Reading";
	}
	else if ([result isEqualToString:@""]) {
		return @"An empty string was read";
	}
	else if (result == nil) {
		return @"Resulting String is NIL";
	}
	else
		return result;
	
	return @"This shouldn't happen";
	*/
}
@end
