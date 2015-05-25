//
//  MPPortManipulationTest.m
//  MacPorts.Framework
//
//  Created by George  Armah on 8/14/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//

#import "MPPortManipulationTest.h"

@interface PortManipulator : NSObject {
	
}
-(BOOL) installUninstallManipulation:(NSString *)portName;
@end

@implementation PortManipulator
-(BOOL) installUninstallManipulation:(NSString *)portName {
	BOOL ret = NO;
	
	MPMacPorts * port = [MPMacPorts sharedInstanceWithPkgPath:@"/Users/juanger/Projects/gsoc09-gui/MPGUI/build/Debug-InstallMacPorts/macports-1.8/Library/Tcl"
	 					portOptions:nil];
	NSLog(@"PkgPath1:  %@", [MPInterpreter PKGPath]);
	MPRegistry * registry = [MPRegistry sharedRegistry];
	NSLog(@"PkgPath2:  %@", [MPInterpreter PKGPath]);
	// Check if portName is installed
	unsigned int installed = [[registry installed:portName] count];
	
	// Search for it
	NSDictionary * searchResult = [port search:portName];
	NSArray * keyArray = [searchResult allKeys];
	MPPort * foundPort = [searchResult objectForKey:[keyArray objectAtIndex:0]];
	
	// If it is installed
	if (installed > 0) {
		NSError * uError;
		//Attempt to uninstall it
		[foundPort uninstallWithVersion:nil error:&uError];
		
		//Check for error
		if (uError != nil) {
			NSLog(@"\n\nUninstallation of %@ failed with error %@", portName, uError);
			//I guess we should just return here
			return ret;
		}
		NSLog(@"Uninstallation Successful.");
		//Uninstallation was successful ... now check registry to make sure its gone
		installed = [[registry installed:portName] count];
		if (installed > 0) { //Uh oh ... is this suppose to happen?
			NSLog(@"%@ is still installed after successful uninstall operation ... double check this from commandline", portName);
			//for now return
			return ret;
		}
		else { // For now end here later on ... add more code to restore system to its original state ... hmm i could just
				// call this method twice
			ret = YES;
			return ret;
		}
		
	}
	else {
		NSError * uError;
		//Attempt to install it
		[foundPort installWithOptions:nil variants:nil error:&uError];
		
		//Check for error
		if (uError != nil) {
			NSLog(@"\n\nInstallation of %@ failed with error %@", portName, uError);
			//I guess we should just return here
			return ret;
		}
		NSLog(@"Installation successful");
		//Installation was successful ... now check registry to make sure its gone
		installed = [[registry installed:portName] count];
        NSLog(@"%@", [registry installed]);
        
		if (installed == 0) { //Uh oh ... is this suppose to happen?
			NSLog(@"%@ is not installed after successful install operation ... double check this from commandline", portName);
			//for now return
			return ret;
		}
		else { // For now end here later on ... add more code to restore system to its original state ... hmm i could just
			// call this method twice
			ret = YES;
			return ret;
		}
	}
	NSLog(@"We shouldn't be here");
	return YES;
}

@end






@implementation MPPortManipulationTest

-(void) setUp {
	mainPort = [MPMacPorts sharedInstance];
}

-(void) tearDown {
	
}

-(void) testSimpleManipulation {
	
	//NSDictionary * searchResult = [mainPort search:@"pngcrush"];
//	NSArray * keyArray = [searchResult allKeys];
//		
//	NSLog(@"\n\n Installing first result from search %@ \n\n", [searchResult objectForKey:[keyArray objectAtIndex:0]]);
//	NSError * iError;
//	[[searchResult objectForKey:[keyArray objectAtIndex:0]] installWithOptions:nil variants:nil error:&iError];
//	
//	//How do we check if a port is installed? Should the methods return BOOL's instead?
//	if (iError != nil) {
//		NSLog(@"\n\n Installation of %@ failed with error %@\n\n", [keyArray objectAtIndex:0], iError);
//	}
//	else{
//		NSLog(@"\n\n Installation successful \n\n");
//		
//		
//	}	
//	
//	//Double check somehow
//	MPRegistry * registry = [MPRegistry sharedRegistry];
//	NSLog(@"\n\n Result from registry is %@ \n\n", [registry installed:[keyArray objectAtIndex:0]]);

	PortManipulator * pm = [[PortManipulator alloc] init];
	STAssertTrue([pm installUninstallManipulation:@"pngcrush"] , @"This test should always return true on success");
	[pm release];
    
}

@end
