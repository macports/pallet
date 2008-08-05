//
//  SimpleDOMPHelperTool.m
//  MacPorts.Framework
//
//  Created by George  Armah on 8/3/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "MPInterpreterProtocol.h"

int main(int argc, char const * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString * tclCmd;
	
	id distObj = [NSConnection 
				  rootProxyForConnectionWithRegisteredName:MP_DOSERVER 
				  host:nil];
	[distObj setProtocolForProxy:@protocol(MPInterpreterProtocol)];
	
	//[distObj log:[NSString stringWithFormat:
//				  @"Number of arguments are %u", argc]];
//	[distObj log:[NSString stringWithFormat:
//				  @"Arguments are %s and %s", argv[0], argv[1]]];
//	
//	[distObj log:@"Getting tclCmd"];
	tclCmd = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	//[distObj log:[NSString stringWithFormat:
//				  @"tclCmd is %@", tclCmd]];
	NSString * result = [distObj evaluateStringFromMPHelperTool:tclCmd];
	
	[distObj setTclCommandResult:result];

	[pool release];
	
	return 0;
}