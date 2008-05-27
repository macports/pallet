/*
 * MPObject.h
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

#import <Foundation/Foundation.h>
#include <tcl.h>

@interface MPObject : NSObject 
{
@private
    char *_cString;
    NSString *_cocoaString;  
    NSDictionary *_cocoaDictionary;  
    Tcl_Obj *_tclObj;
}

/** creation **/
+ (MPObject *) objectWithString: (NSString *)string;
+ (MPObject *) objectWithTclObj: (Tcl_Obj *)tclObj;
- (id) initWithTclObj: (Tcl_Obj*)tclObject;

/** accessors */
- (Tcl_Obj *) tclObj;
- (char *) cString;
- (NSString *) stringValue;
- (NSDictionary *) dictionaryValue;

/** comparisons **/
- (BOOL) isEqual: (id)object;
- (BOOL) containsString: (NSString *)substring;

@end
