/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 *	George Armah <armahg@macports.org>
 *
 *	Copyright (c) 2008 George Armah <armahg@macports.org>
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

//MPInterpreter needs to be exposed (in a controlled manner)
//to MPHelperTool. There are various reasons for doing this.

//- The first is that, there is no way (that I know so far) to access
//	the created Tcl interpreter from the Helper Tool. Even if we could
//	access it, I doubt that the Notifications mechanism will still be
//	able to work on a local level since MPHelperTool is a completely 
//	different process. For this reason I am adopting the following
//	strategy

//	I'll illustrate with a port sync example. Note that all the necessary
//	Distributed Objects stuff is assumed to have already been set up.
//	1)	There is a [[MPMacPorts sharedInstance] sync] call
//	2)	This calls an internal [interp evaluateStringWithMPHelperTool@"mportsync"]
//		which then invokes MPHelperTool using BAS protocol. Passing the argument
//		@"mportsync" within the request dictionary.
//	3)	So now we are within MPHelperTool. We first obtain the vended of instance
//		MPInterpreter (which invoked this all in the first place ... ha) and then
//		call an this protocol's method [interp evaluateTclStringFromMPHelperTool: ]  
//		This takes us back to
//		MacPorts.Framework space where everything happens as expected and then
//		(hopefully without any hiccups) returns the string result and error object.
//	4)	Now we can put the string returned into the response dictionary and pass
//		it back as the return value for the message passed in 2)
//
//	You can probably tell that the above solution is kind of clunky. But its a
//	start. I'm not too worried about security being compromised since I am sure
//	of what happens in MPInterpreter space. In any event, using this method is
//	no more dangerous than running "sudo port -dv sync" from Terminal.
//
//	I am still thinking of a way to implement error handling within the new set up.
//	One possiblity would be to have MPInterpreter's evaluateStringWithMPHelperTool:
//	message do an internal NSError creation depending on whether or not the
//	response dictionary contians a value for kNSError. This is going to be a 
//	CFDictionaryRef object from which I'll have enough information to create
//	a reasonably informative NSError object. Thats for later though .... for 
//	now lets get basic functionally going first.

#define MP_DOSERVER				@"MacPortsDistributedObjectServer"

@protocol MPInterpreterProtocol

- (bycopy NSString *)evaluateStringFromMPHelperTool:(in bycopy NSString *)statement;
- (void) setTclCommand:(in bycopy NSString *)tclCmd;
- (bycopy NSString *) getTclCommand;
- (void) setTclCommandResult:(in bycopy NSString *)tclCmdResult;
- (bycopy NSString *) getTclCommandResult;
- (void) log:(in bycopy id)logOutput;
@end
