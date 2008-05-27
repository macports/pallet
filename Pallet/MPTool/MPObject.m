/*
 * MPObject.m
 * DarwinPorts
 *
 * Copyright (c) 2002-2003, Apple Computer, Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Apple Computer, Inc. ("Apple") nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MPObject.h"


@implementation MPObject
/*
    Thin obj-c wrapper for TclObj.  Should not have any specific knowledge of darwinports data-types/structures
*/


/** Creation **/


+ (MPObject *) objectWithString: (NSString *)string
{
    const char *cString = [string cString];
    Tcl_Obj *tclObj = Tcl_NewStringObj(cString, strlen(cString));
    MPObject *object = [[[self alloc] initWithTclObj: tclObj] autorelease];
    
    return object;
}


+ (MPObject *) objectWithTclObj: (Tcl_Obj *)tclObj
{
    return [[[self alloc] initWithTclObj: tclObj] autorelease];
}


- (id) initWithTclObj: (Tcl_Obj *)tclObj
{
    if (self = [super init])
    {
        _tclObj = tclObj;
        Tcl_IncrRefCount(_tclObj);
    }
    return self;
}


- (void) dealloc 
{
    Tcl_DecrRefCount(_tclObj);
    [_cocoaString release];
    if (_cString != NULL)
        free(_cString);
    [super dealloc];
}


/** Accessors */


- (Tcl_Obj *) tclObj
{
    return _tclObj;
}


- (char *) cString 
{
    /*
     * Tcl_Obj value pointers are only safe
     * until the next Tcl_Get*FromObj call.
     */
    if (_cString == NULL) {
        _cString = strdup(Tcl_GetStringFromObj(_tclObj, NULL));
    }
    return _cString;
}


- (NSString*) stringValue 
{
    if (nil == _cocoaString)
    {
        _cocoaString = [[NSString alloc] initWithCString: [self cString]];
    }
    return _cocoaString;
}

- (NSDictionary*) dictionaryValue 
{
    Tcl_Obj **elemPtrs;
    int elemLen, i;

    if (nil == _cocoaDictionary)
    {
    	if (Tcl_ListObjGetElements(NULL, _tclObj, &elemLen, &elemPtrs) != TCL_OK)
	    return nil;

	if (elemLen & 1 || elemLen == 0)
	    return nil;

	NSMutableArray *keys = [NSMutableArray array];
	NSMutableArray *values = [NSMutableArray array];

	for (i = 0; i < elemLen; i += 2) {
	    [keys addObject: [NSString stringWithCString: Tcl_GetString(elemPtrs[i])]];
	    [values addObject: [NSString stringWithCString: Tcl_GetString(elemPtrs[i + 1])]];
	}

	_cocoaDictionary = [NSDictionary dictionaryWithObjects: values forKeys: keys];
    }

    return _cocoaDictionary;
}


- (NSString*) description 
{
    return [self stringValue];
}



/** Comparisons */


- (unsigned) hash 
{
    return [[self stringValue] hash];
}


- (BOOL) isEqual: (id)object 
{
    return [[self stringValue] isEqualToString: [object stringValue]];
}


- (BOOL) containsString: (NSString *)substring 
{
    return ([[self stringValue] rangeOfString: substring].location != NSNotFound);
}


@end
