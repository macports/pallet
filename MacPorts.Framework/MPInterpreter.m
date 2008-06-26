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

- (id) init {
	if (self = [super init]) {
		_interpreter = Tcl_CreateInterp();
		if(_interpreter == NULL) {
			NSLog(@"Error in Tcl_CreateInterp, aborting.");
		}
		if(Tcl_Init(_interpreter) == TCL_ERROR) {
			NSLog(@"Error in Tcl Init: %s", Tcl_GetStringResult(_interpreter));
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
    //do nothing
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
