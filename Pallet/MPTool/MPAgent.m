/*
 * MPAgent.m
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

#import "MPAgent.h"
#import "MPObject.h"

@implementation MPAgent
/*
    Serves as a bridge between the GUI app and the tcl interpreter.
    Uses distributed objects to communicate with a delegte (GUI front-end).
    All values exposed by the APIs to this class are generic objective-c data-types
    and not TCL MPObjects... clients talking to this class should not know or care that
    there's a tcl interpreter hiding underneath.   This class should also be the place to
    encapsulate all knowledge about the internal structure/constants of the ports system
    so that clients do not need to know about those details.
    This class is multi-threaded but all port operations are currently serialized
    (see more comments on this below).
    The agent does not cache any information but rather always calls the tcl
    engine to talk to the ports collection and get the most recent information.
    Caching should (and is) performed in the application front-end.
*/

/** Init and clean-up **/


- (id) init
{
    
    if (self = [super init])
    {

        _portExecLock = [[NSLock alloc] init];
        _ports = [[NSMutableDictionary alloc] init];

		// this needs to be passed at launch time from launching application to completely abstract this
		_applicationMessagePort = MPAppMessagePort;
		
        // configure our d.o. connection
        _connection = [NSConnection defaultConnection];
        [_connection setRootObject: self];
        [_connection enableMultipleThreads];
        [_connection setDelegate: self];
        if ([_connection registerName: MPAgentMessagePort] == NO) 
        {
            NSLog(@"Couldn't register server on this host.");
            exit(0);
        } else {
			NSLog(@"Registered %@ on this host.", MPAgentMessagePort);
		}

        [[NSNotificationCenter defaultCenter] addObserver:self
            selector: @selector(connectionDidDie:)
            name: NSConnectionDidDieNotification
            object: _connection];
 
    }
    return self;

}


- (void) dealloc
{
    [_interp release];
    [_portExecLock release];
    [super dealloc];
}


- (BOOL) interpInit: (MPInterp *) interp
{
    // load required Tcl packages and set up UI call back
	NSLog(@"interpInit: enter");
    if(![interp loadPackage: MPPackageName version: MPPackageVersion usingCommand: MPPackageInit])
        return (NO);
	NSLog(@"interpInit: package loaded");
    if(![interp redirectCommand: MPUIPuts toObject: self])
        return (NO);
	NSLog(@"interpInit: UI commands redirected");
    return (YES);
}


/** D.O. connection management **/

- (BOOL) agentInit
{
    // configure our tcl interpreter
	NSLog(@"agentInit: enter");
    _interp = [[MPInterp alloc] init];
	NSLog(@"agentInit: interperter allocated");
    return ([self interpInit: _interp]);
}

- (BOOL) connection: (NSConnection *)parentConnection shouldMakeNewConnection:(NSConnection *)newConnection
{
    /*
     * Ensure that connectionDidDie: is called if newConnection
     * dies without terminate being called
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
	selector: @selector(connectionDidDie:)
        name: NSConnectionDidDieNotification
        object: newConnection];
    return YES;
}


- (void) connectionDidDie: (id)connection
{
    exit(0);
}


- (oneway void) terminate
{
    [self performSelector: @selector(connectionDidDie:) withObject: self afterDelay: 0.0];
}



/** Port operations **/


- (bycopy NSData *) portsData
/*
    Returns a serialized property list describing the ports collection
*/
{
    
    Tcl_Obj **objv;
    int count = 0, i=0;
    MPObject *result;
    NSString *error;
    NSData *portsData;
        
    [_ports removeAllObjects];
    result = [_interp evaluateCommand: [MPObject objectWithString: MPSearchCommand] 
        withObject: [MPObject objectWithString: MPAnyPortArgument]];
    Tcl_ListObjGetElements(NULL, [result tclObj], &count, &objv);

    while (++i < count) 
    {	

        NSMutableDictionary *portDict = [NSMutableDictionary dictionary];
        Tcl_Obj **innerobjs;
        int innercount = 0, j = 0;    
        Tcl_ListObjGetElements(NULL, objv[i++], &innercount, &innerobjs);

        while (j < innercount)
        {

            MPObject *keyObject = [MPObject objectWithTclObj: innerobjs[j++]];
            MPObject *valueObject = [MPObject objectWithTclObj: innerobjs[j++]];
            NSString *key = [keyObject stringValue];
            id value;
            
            if ([key isEqualToString: MPCategoriesKey] ||
                [key isEqualToString: MPMaintainersKey])
            {
                NSEnumerator *enm = [[[valueObject stringValue] componentsSeparatedByString: @" "] objectEnumerator];
                NSString *component;
                value = [NSMutableArray array];
                while (component = [enm nextObject])
                {
                    if (![value containsObject: component])
                    {
                        [value addObject: component];
                    }
                }
    
            }
            else if ([key rangeOfString: MPDependsKey].location != NSNotFound)
            {
                NSEnumerator *dependencyEnm = [[[valueObject stringValue] componentsSeparatedByString: @" "] objectEnumerator];
                NSString *component;
                value = [NSMutableArray array];
                while (component = [dependencyEnm nextObject])
                {
                    NSString *dependencyName = [[component componentsSeparatedByString: @":"] objectAtIndex: 2];
                    if (![value containsObject: dependencyName])
                    {
                        [value addObject: dependencyName];
                    }
                }
                key = MPDependsKey;
            }
            else
            {
                value = [valueObject stringValue];
            }
            [portDict setObject: value forKey: key];

        }
        [_ports setObject: portDict forKey: [portDict objectForKey: MPNameKey]];
    }

    // we serialize the data before returning it so that we can pass a deep copy of
    // the entire dictionary back in a single D.O. exchange.   if we just pass
    // a copy of _ports back then the GUI app is still forced to query objects
    // stored in the dict via d.o. proxies - which is dirt slow when refreshing
    // the outline view in the GUI    
    portsData = [NSPropertyListSerialization dataFromPropertyList: _ports 
        format: NSPropertyListXMLFormat_v1_0 
        errorDescription: &error];

    return portsData;
    
}

- (oneway void) executeTarget: (in bycopy NSString *)target forPortName: (in bycopy NSString *)portName
/*
    Detaches a new thread to perform the specified target on the specified port... 
*/
{
    NSDictionary *op = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        portName, @"portName",
        target, @"target",
        [[_ports objectForKey: portName] objectForKey: MPPortURLKey], @"url",
        nil];
    [NSThread detachNewThreadSelector: sel_getUid("_threadForOperation:") 
        toTarget: self 
        withObject: op];
}


/** Execution thread methods */

/*
    Everything beyond this point code executes in secondary threads.  I've made a conscious effort to not share any objects (except for the _portExecLock) between the primary thread and the secondary threads to minimize the need to worry about thread-safe data sharing between threads.
    Even though we have a separate thread for each operation all operations are currently serialized using the _portExecLock.
    If we allow multiple simultaneous operations we also need to think about situations such as what happens if you start installing Port A and Port B both of which have a dependency on C?  Does C get installed twice?  Or even worse what if you start installing port A which depends on port C and simultaneously start uninstalling C?  etc.   For now easier to sidestep the whole issue by serializing everything.
*/


- (void) _threadForOperation: (NSMutableDictionary *)op
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MPInterp *interp = [[MPInterp alloc] init];

    /* Initialize new interpreter */
    if (![self interpInit: interp])
        return;
    
    // establish a separate connection for communication from this thread
    // back to the Pallet.app
    NSConnection *connection = [NSConnection connectionWithRegisteredName:_applicationMessagePort host: nil];
    id <MPDelegateProtocol> delegate = [connection rootProxy];
    [connection enableMultipleThreads];    
    [(NSDistantObject *)delegate setProtocolForProxy:@protocol(MPDelegateProtocol)];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector: @selector(connectionDidDie:)
        name: NSConnectionDidDieNotification
        object: connection];
    
    [[[NSThread currentThread] threadDictionary] setObject: delegate forKey: @"delegate"];
    
    if ([delegate shouldPerformTarget: [op objectForKey: @"target"] forPortName: [op objectForKey: @"portName"]])
    {
        MPObject *result = nil;
        [_portExecLock lock]; // this can block for a long time if another op is in progress
        [delegate willPerformTarget: [op objectForKey: @"target"] forPortName: [op objectForKey: @"portName"]];
        _currentOp = op;
        MPObject *workName = [interp evaluateCommand: [MPObject objectWithString: MPOpenCommand]
                                          withObject: [MPObject objectWithString: [op objectForKey: @"url"]]];
        if ([interp succeeded])
        {
            result = [interp evaluateCommand: [MPObject objectWithString: MPExecCommand]
                                 withObjects: workName : [MPObject objectWithString: [op objectForKey: @"target"]]];
            if ([interp succeeded]) 
            {
                result = [interp evaluateCommand: [MPObject objectWithString: MPCloseCommand] withObject: workName];            
            }
        }
        _currentOp = nil;
        [_portExecLock unlock];
        [delegate didPerformTarget: [op objectForKey: @"target"] forPortName: [op objectForKey: @"portName"] withResult: [result stringValue]];
    }

    // Unregister for NSConnectionDidDieNotification before
    // auto-releasing the connection object
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name: NSConnectionDidDieNotification
        object: connection];

    [op release];
    [pool release];
    /* Do NOT release interpreter until ALL MPObjects are released */
    [interp release];
}


- (MPObject *) ui_puts: (NSArray *)array 
{
    NSDictionary *message = [[array objectAtIndex: 1] dictionaryValue];
    if (message == nil)
    	return [MPObject objectWithString: MPNoResult];

    NSString *data = [message objectForKey: @"data"];
    NSString *priority = [message objectForKey: @"priority"];
    if (data == nil || priority == nil)
    	return [MPObject objectWithString: MPNoResult];

    id delegate = [[[NSThread currentThread] threadDictionary] objectForKey: @"delegate"];
    [delegate displayMessage: message forPortName: [_currentOp objectForKey: @"portName"]];
    return [MPObject objectWithString: MPYesResult];
}


@end
