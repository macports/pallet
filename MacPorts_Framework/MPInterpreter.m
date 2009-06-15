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
#include "MPHelperNotificationsProtocol.h"
static AuthorizationRef internalMacPortsAuthRef;
static NSString* PKGPath = @"/Library/Tcl";


#pragma mark -

@implementation MPInterpreter

#pragma mark Notifications Code
int Notifications_Send(int objc, Tcl_Obj *CONST objv[], int global, Tcl_Interp *interpreter) {
	NSString *name;
	NSMutableString *msg;
	
	//Our info dictionary is of size 5 and contains the following keys
	//NOTIFICATION_NAME - e.g. MPWARN, MPDEBUG etc.
	//CHANNEL - eg. stdout, stderr
	//PREFIX - prefix string for this message e.g. DEBUG:
	//METHOD - the function whose operation led to this notification eg. sync, selfupdate
	//MESSAGE - the message logged to channel
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:5];
	MPNotifications *mln = [MPNotifications sharedListener];
	
	int tclCount;
	int tclResult;
	const char **tclElements;
	
	name = [NSString stringWithUTF8String:Tcl_GetString(*objv)];
	//NSLog(@"name is %@", name);
	[info setObject:name forKey:MPNOTIFICATION_NAME];
	
	//Name and Notification constants should match. Convention
	//used is MPPriorityNotification. Is it ok to just return TCL_OK ?
	if( [mln checkIfNotificationBlocked:name] ){
		return TCL_OK;
	}
	
	++objv; --objc;
	tclResult = Tcl_SplitList(interpreter, Tcl_GetString(*objv), &tclCount, &tclElements);
	//NSLog(@"tclElements is %S and tclCount is %i", &tclElements, tclCount);
	
	if (tclResult == TCL_OK) {
		
		//I have sacrificed generality for simplicity in the code below
		if (tclCount > 0) { 
			[info setObject:[NSString stringWithUTF8String:tclElements[0]] forKey:MPCHANNEL];
			
			if(tclElements[1])
				[info setObject:[NSString stringWithUTF8String:tclElements[1]] forKey:MPPREFIX];
			else
				[info setObject:@"None" forKey:MPPREFIX];
		}
		else {
			[info setObject:@"None" forKey:MPCHANNEL];
			[info setObject:@"None" forKey:MPPREFIX];
		}
		
		
		//Get ui_* message separately Hopefully this should never be null 
		++objv; --objc;
		if(objv != NULL) {
			msg = [NSMutableString stringWithUTF8String:Tcl_GetString(*objv)];
			//NSLog(@"Message is %@", msg);
			
			//strip off "--->" over here
			NSArray * temp = [msg componentsSeparatedByString:@"--->"];
			[msg setString:[temp componentsJoinedByString:@""]];
			[info setObject:msg forKey:MPMESSAGE];
		}
		
		//Get the Tcl function that called this method
		if (! [[mln performingTclCommand] isEqualToString:@""]) {
			[info setObject:[mln performingTclCommand] forKey:MPMETHOD];
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

#pragma mark MPInterpreter Code

//This variable is set during initialization and is
//not changed thereafter. Is sole purpose is to enable
//passing the path to macports1.0 package to the helper
//tool
static NSString * tclInterpreterPkgPath = nil;

+(NSString*) PKGPath {
	return PKGPath;
}

+(void) setPKGPath:(NSString*)newPath {
    if([PKGPath isNotEqualTo:newPath]) {
        [PKGPath release];
        PKGPath = [newPath copy];
        //I should check if interp is nil. *not needed now
        MPInterpreter *interp = (MPInterpreter*) [[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"];
        [interp resetTclInterpreterWithPath:PKGPath];
    }
}

#pragma mark -
#pragma mark Internal Methods
//Internal method for initializing actual C Tcl interpreter
//Should I be using a double pointer like is done for NSError ?
-(BOOL) initTclInterpreter:(Tcl_Interp * *)interp withPath:(NSString *)path {
	BOOL result = NO;
	*interp = Tcl_CreateInterp();
	
	if(*interp == NULL) {
		NSLog(@"Error in Tcl_CreateInterp, aborting.");
		return result;
	}
	
	if(Tcl_Init(*interp) == TCL_ERROR) {
		NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(*interp));
		Tcl_DeleteInterp(*interp);
		return result;
	}
	
	if (path == nil)
		path = PKGPath;
	
	
	NSString * mport_fastload = [[@"source [file join \"" stringByAppendingString:path]
								 stringByAppendingString:@"\" macports1.0 macports_fastload.tcl]"];
	if(Tcl_Eval(*interp, [mport_fastload UTF8String]) != TCL_OK) {
		NSLog(@"Error in Tcl_EvalFile macports_fastload.tcl: %s", Tcl_GetStringResult(*interp));
		Tcl_DeleteInterp(*interp);
		return result;
	}
	
	
	Tcl_CreateObjCommand(*interp, "notifications", Notifications_Command, NULL, NULL);
	if (Tcl_PkgProvide(*interp, "notifications", "1.0") != TCL_OK) {
		NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(*interp));
		Tcl_DeleteInterp(*interp);
		return result;
	}
	
	if( Tcl_EvalFile(*interp, [[[NSBundle bundleWithIdentifier:@"org.macports.frameworks.macports"] 
								pathForResource:@"init" 
								ofType:@"tcl"] UTF8String]) != TCL_OK) {
		NSLog(@"Error in Tcl_EvalFile init.tcl: %s", Tcl_GetStringResult(*interp));
		Tcl_DeleteInterp(*interp);
		return result;
	}
	
	result = YES;
	return result;
}

//Internal method for setting port Tcl_interpreter options
-(BOOL) setOptions:(NSArray *)options forTclInterpreter:(Tcl_Interp * *)interp {
	BOOL result = NO;
	
	//I wish I could use fast enumeration
	if (options != nil) {
		if ([options count] > 0 ) {
			NSEnumerator * optionsEnum = [options objectEnumerator];
			id opt;
			
			while ((opt = [optionsEnum nextObject])) {
				if (Tcl_Eval(*interp , [[NSString stringWithFormat:@"set ui_options(%@) \"yes\"", opt] UTF8String]) != TCL_OK) {
					NSLog(@"Error in Tcl_Eval for set ui_options: %s", Tcl_GetStringResult(*interp));
					return result;
				}
			}
			result = YES;
			return result;
		}
	}
	
	return result;
}

//Wrapper method for above. Used when 
-(BOOL) setOptionsForNewTclPort:(NSArray *)options {
	BOOL result = NO;
	
	//First delete our internal Tcl interpreter
	Tcl_DeleteInterp(_interpreter);
	
	if (tclInterpreterPkgPath == nil) 
		result = [self initTclInterpreter:&_interpreter withPath:PKGPath];
	else 
		result = [self initTclInterpreter:&_interpreter withPath:tclInterpreterPkgPath];
	
	BOOL tempResult = [self setOptions:options forTclInterpreter:&_interpreter];
		
	
	
	
	return (result && tempResult) ;
} 

-(BOOL) resetTclInterpreterWithPath:(NSString*) path {
    Tcl_DeleteInterp(_interpreter);
    return [self initTclInterpreter:&_interpreter withPath:PKGPath];
}

- (id) initWithPkgPath:(NSString *)path portOptions:(NSArray *)options {
	if (self = [super init]) {
		[self initTclInterpreter:&_interpreter withPath:path];
		
		//set port options maybe I should do this elsewhere?
		defaultPortOptions = [NSArray arrayWithObjects: MPDEBUGOPTION, nil];
		if (options == nil)
			options = defaultPortOptions;
		[self setOptions:options forTclInterpreter:&_interpreter];
		
		//Initialize helperToolInterpCommand
		helperToolInterpCommand = @"";
		helperToolCommandResult = @"";
		
		//Initialize the MacPorts Tcl Package Path string
		tclInterpreterPkgPath = [NSString stringWithString:path];
		
	}
	return self;
}


#pragma mark API methods
- (id) init {
	return [self initWithPkgPath:PKGPath portOptions:nil];
}

+ (MPInterpreter*)sharedInterpreterWithPkgPath:(NSString *)path {
	return [self sharedInterpreterWithPkgPath:path portOptions:nil];
}

+ (MPInterpreter*)sharedInterpreter{
	return [self sharedInterpreterWithPkgPath:PKGPath];
}

+ (MPInterpreter*)sharedInterpreterWithPkgPath:(NSString *)path portOptions:(NSArray *)options {
	@synchronized(self) {
        if ([PKGPath isNotEqualTo:path]) {
            [self setPKGPath:path];
        }
        
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"] == nil) {
			[[self alloc] initWithPkgPath:path portOptions:options]; // assignment not done here
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
		array = [[[NSMutableArray alloc] init] autorelease];
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
	unsigned int array_count = [array count];
	
	for (i = 0; i < array_count; i += 2) {
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


#pragma mark -
#pragma mark -evaluateString* routines

- (NSString *)evaluateStringAsString:(NSString *)statement error:(NSError**)mportError{
	//NSLog(@"Calling evaluateStringAsString with argument %@", statement);
	
	int return_code = Tcl_Eval(_interpreter, [statement UTF8String]);
	
	//Should I check for (return_code != TCL_Ok && return_code != TCL_RETURN) instead ?
	if (return_code != TCL_OK) {
		
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

- (NSString *)evaluateStringWithPossiblePrivileges:(NSString *)statement error:(NSError **)mportError {
	
	
	
	//N.B. I am going to insist that funciton users not pass in nil for the
	//mportError parameter
	NSString * firstResult;
	NSString * secondResult;
	
	*mportError = nil;
	firstResult = [self evaluateStringAsString:statement error:mportError];
	
	//Because of string results of methods like mportsync (which returns the empty string)
	//the only way to truly check for an error is to check the mportError parameter.
	//If it is nil then there was no error, if not we re-evaluate with privileges using
	//the helper tool
	
	if ( *mportError != nil) {
		*mportError = nil; 
		secondResult = [self evaluateStringWithMPHelperTool:statement error:mportError];
		
		return secondResult;
	}
	
	return firstResult;
}

//NOTE: We expect the Framework client to initialize the AuthorizationRef
//Completely before calling any privileged operation. If not we will pass in
//a barely initialzed one. This method returns nil if there is an error
- (NSString *) evaluateStringWithMPHelperTool:(NSString *) statement error:(NSError **)mportError {
	OSStatus        err;
    BASFailCode     failCode;
    NSString *      bundleID;
    NSDictionary *  request;
    CFDictionaryRef response;
	NSString * result = nil;
	
	response = NULL;
	
	//Creating file path for IPC with helper tool
	NSString * ipcFilePath = [NSString stringWithFormat:@"%@_%@", @kServerSocketPath, [NSDate date]];
	NSString * ipcFilePathCopy = [NSString stringWithString:ipcFilePath];
	
	
	//We need to use the notificationsObject to set up IPC with the helper tool
	//I hope BAS's main method is blocking ... it should be since we obtain
	//a return value
	MPNotifications * notificationObject = [MPNotifications sharedListener];
	//if ([notificationObject respondsToSelector:@selector(prepareIPCServerThread)]) {
	NSLog(@"PREPARING SERVER THREAD");
	[notificationObject prepareIPCServerThread];
	//}
	
	//if ([notificationObject respondsToSelector:@selector(startServerThread)]) {
	NSThread * cThread = [NSThread currentThread];
	NSLog(@"STARTING SERVER THREAD with previous thread %@", [cThread threadDictionary]);
	
	//This is important to note ... the tcl command being executed is saved in the
	//current thread's thread dictionary in the upper tier method that calls this one. 
	// This means we are only going to guarantee
	//thread saftey for Framework clients at the the level of MPMacPorts, MPPorts etc. and above
	NSDictionary * serverInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								 ipcFilePathCopy, @"ipcFilePath",
								 [[MPNotifications sharedListener] performingTclCommand], @"currentMethod",
								 nil];
	
	[NSThread detachNewThreadSelector:@selector(startIPCServerThread:) 
							 toTarget:notificationObject 
						   withObject:serverInfo];
	//[notificationObject startIPCServerThread];
	//}
	
	
	//Retrieving the path for interpInit.tcl for our helper tool
	NSString * interpInitPath = [[NSBundle bundleForClass:[MPInterpreter class]] 
								 pathForResource:@"interpInit" ofType:@"tcl"];
	
		
	
	
	
	request = [NSDictionary dictionaryWithObjectsAndKeys:
			   @kMPHelperEvaluateTclCommand, @kBASCommandKey,
			   statement, @kTclStringToBeEvaluated, 
			   tclInterpreterPkgPath, @kTclInterpreterInitPath ,
			   interpInitPath, @kInterpInitFilePath, 
			   ipcFilePath, @kServerFileSocketPath , nil];
	
	assert(request != NULL);
	
	bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	
	assert(bundleID != NULL);
	
	
	//In order to make the framework work normally by default ... we do a bare initialization
	//of internalMacPortsAuthRef if the delegate hasn't iniitialzed it already
	if (internalMacPortsAuthRef == NULL) {
		OSStatus res = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &internalMacPortsAuthRef);
		assert(res == noErr);
	}
	
	BASSetDefaultRules(internalMacPortsAuthRef, 
					   kMPHelperCommandSet, 
					   (CFStringRef) bundleID, 
					   NULL);
	
	//NSLog(@"BEFORE Tool Execution request is %@ , response is %@ \n\n", request, response);
	err = BASExecuteRequestInHelperTool(internalMacPortsAuthRef, 
										kMPHelperCommandSet, 
										(CFStringRef) bundleID, 
										(CFDictionaryRef) request, 
										&response);
	if (err == noErr){// retrieve result here if available
		if( response != NULL)
			result = (NSString *) (CFStringRef) CFDictionaryGetValue(response, CFSTR(kTclStringEvaluationResult));
	}
	else { //Try to recover error
		failCode = BASDiagnoseFailure(internalMacPortsAuthRef, (CFStringRef) bundleID);
		
		
		//Need to pass in URL's to helper and install tools since I
		//modified BASFixFaliure
		NSBundle * mpBundle = [NSBundle bundleForClass:[self class]];
		
		NSString * installToolPath = [mpBundle pathForResource:@"MPHelperInstallTool" ofType:nil];
		assert(installToolPath != nil);
		NSURL * installToolURL = [NSURL fileURLWithPath:installToolPath];
		assert(installToolURL != nil);
		
		NSString * helperToolPath = [mpBundle pathForResource:@"MPHelperTool" ofType:nil];
		assert(helperToolPath != nil);
		NSURL * helperToolURL = [NSURL fileURLWithPath:helperToolPath];
		assert(helperToolURL != nil);
		
		err = BASFixFailure(internalMacPortsAuthRef, 
							(CFStringRef) bundleID, 
							(CFURLRef) installToolURL,
							(CFURLRef) helperToolURL,
							failCode);
		
		
		//Making the following assumption in error handling. If we return
		//a noErr then response dictionary cannot be nil since everything went ok. 
		//Hence I'm only checking for errors WITHIN the following blocks ...
		if (err == noErr) {
			err = BASExecuteRequestInHelperTool(internalMacPortsAuthRef, 
												kMPHelperCommandSet, 
												(CFStringRef) bundleID, 
												(CFDictionaryRef) request, 
												&response);
			if (err == noErr){// retrieve result here if available
				if( response != NULL)
					result = (NSString *) (CFStringRef) CFDictionaryGetValue(response, CFSTR(kTclStringEvaluationResult));
			}
			else { //If we executed unsuccessfully
				if (mportError != NULL) {
					NSError * undError = [[[NSError alloc] initWithDomain:NSOSStatusErrorDomain 
																	 code:err 
																 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		   NSLocalizedString(@"Check error code for OSStatus returned",@""), 
																		   NSLocalizedDescriptionKey,
																		   nil]] autorelease];
					
					*mportError = [[[NSError alloc] initWithDomain:MPFrameworkErrorDomain 
															  code:MPHELPINSTFAILED 
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	NSLocalizedString(@"Unable to execute MPHelperTool successfuly", @""), 
																	NSLocalizedDescriptionKey,
																	undError, NSUnderlyingErrorKey,
																	NSLocalizedString(@"BASExecuteRequestInHelperTool execution failed", @""),
																	NSLocalizedFailureReasonErrorKey,
																	nil]] autorelease];
				}
			}
		}
		else {//This means FixFaliure failed ... Report that in returned error
			if (mportError != NULL) {
				//I'm not sure of exactly how to report this error ... 
				//Do we need some error codes for our domain? I'll define one
				NSError * undError = [[[NSError alloc] initWithDomain:NSOSStatusErrorDomain 
																 code:err 
															 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	   NSLocalizedString(@"Check error code for OSStatus returned",@""), 
																	   NSLocalizedDescriptionKey,
																	   nil]] autorelease];
				
				*mportError = [[[NSError alloc] initWithDomain:MPFrameworkErrorDomain 
														  code:MPHELPINSTFAILED 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																NSLocalizedString(@"Unable to fix faliure for MPHelperTool execution", @""), 
																NSLocalizedDescriptionKey,
																undError, NSUnderlyingErrorKey,
																NSLocalizedString(@"BASFixFaliure routine wasn't completed successfuly", @""),
																NSLocalizedFailureReasonErrorKey,
																nil]] autorelease];
			}
		}
	}
	
	//NSLog(@"AFTER Tool Execution request is %@ , response is %@ \n\n", request, response);
	
	return result;
}


#pragma mark -
#pragma mark Authorization Code

- (BOOL)checkIfAuthorized {
	if  (internalMacPortsAuthRef == NULL ) {
		return NO;
	}
	return YES;
}

-(void)setAuthorizationRef:(AuthorizationRef)authRef {
	//I can do this since Framework client responsible
	//for managing memory for Authorization
	internalMacPortsAuthRef = authRef;
}



#pragma mark -
#pragma mark For Internal Use

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


- (Tcl_Interp *) sharedInternalTclInterpreter {
	return _interpreter;
}

@end
