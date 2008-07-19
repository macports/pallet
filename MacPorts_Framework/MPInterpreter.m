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

@implementation MPInterpreter

#pragma mark Notifications Code 
int Notifications_Send(int objc, Tcl_Obj *CONST objv[], int global, Tcl_Interp *interpreter) {
	//NSLog(@" INSIDE Notifications_Send METHOD");
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

#pragma mark MPInterpreter Code
- (id) init {
	if (self = [super init]) {
		_interpreter = Tcl_CreateInterp();
		if(_interpreter == NULL) {
			NSLog(@"Error in Tcl_CreateInterp, aborting.");
		}
		if(Tcl_Init(_interpreter) == TCL_ERROR) {
			NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
		/*
		 //TO DO ...
		 //Use client provided .tcl file if any
		 
		 //Finally load our own init.tcl file
		 */
		
		Tcl_CreateObjCommand(_interpreter, "notifications", Notifications_Command, NULL, NULL);
		
		if (Tcl_PkgProvide(_interpreter, "notifications", "1.0") != TCL_OK) {
			NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		if( Tcl_EvalFile(_interpreter, [[[NSBundle bundleWithIdentifier:@"org.macports.frameworks.macports"] pathForResource:@"init" ofType:@"tcl"] UTF8String]) != TCL_OK) {
			NSLog(@"Error in Tcl_EvalFile: %s", Tcl_GetStringResult(_interpreter));
			Tcl_DeleteInterp(_interpreter);
		}
		
	}
	return self;
}

+ (MPInterpreter*)sharedInterpreter {
	@synchronized(self) {
		if ([[[NSThread currentThread] threadDictionary] objectForKey:@"sharedMPInterpreter"] == nil) {
			[[self alloc] init]; // assignment not done here
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

- (NSString *)evaluateArrayAsString:(NSArray *)statement {
	return [self evaluateStringAsString:[statement componentsJoinedByString:@" "]];
}

- (NSString *)evaluateStringAsString:(NSString *)statement {
	Tcl_Eval(_interpreter, [statement UTF8String]);
	return [NSString stringWithUTF8String:Tcl_GetStringResult(_interpreter)];
}

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


@end
