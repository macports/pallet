//
//  MPHelperToolIPCTester.m
//  MacPorts.Framework
//
//  Created by George  Armah on 8/24/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <MacPorts/MacPorts.h>



@interface PortManipulator : NSObject {
	
}
-(BOOL) installUninstallManipulation:(NSString *)portName;
-(BOOL) selfUpdate;
-(void) registerForLocalNotifications;

@end

@implementation PortManipulator

-(id) init {
	self = [super init];
	if (self != nil) {
		//[self registerForLocalNotifications];
	}
	return self;
}

-(void) registerForLocalNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPINFO
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPMSG
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPERROR
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPWARN
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPDEBUG
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:MPDEFAULT
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(respondToLocalNotification:) 
												 name:@"testMacPortsNotification"
											   object:nil];
}

-(void) respondToLocalNotification:(NSNotification *)notification {
	id sentDict = [notification userInfo];
	
	//Just NSLog it for now
	if(sentDict == nil)
		NSLog(@"MPMacPorts received notification with empty userInfo Dictionary");
	else
		NSLog(@"MPMacPorts received notification with userInfo %@" , [sentDict description]);
}


-(BOOL) selfUpdate {
	NSError *err = nil;
	[[MPMacPorts sharedInstance] selfUpdate:&err];
	
	if( err != nil) {
		NSLog(@"%@", [err description]);
		return NO;
	}
	return YES;
}

-(BOOL) installUninstallManipulation:(NSString *)portName {
	BOOL ret = NO;
	
	MPRegistry * registry = [MPRegistry sharedRegistry];
	MPMacPorts * port = [MPMacPorts sharedInstance];
	
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
		
		//Installation was successful ... now check registry to make sure its gone
		installed = [[registry installed:portName] count];
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

int main(int argc, char const * argv[]) {
	
	[[MPMacPorts sharedInstance] setAuthorizationMode:YES];
	
	
	PortManipulator * pm = [[PortManipulator alloc] init];
	
	if([pm installUninstallManipulation:@"pngcrush"]) {
		NSLog(@"pngcrush INSTALLATION SUCCESSFUL");
	}
    /*
	else {
		NSLog(@"pngcrush INSTALLATION UNSUCCESSFUL");
	}
	
	if([pm selfUpdate]) {
		NSLog(@"SELFUPDATE SUCCESSFUL");
	}
	else {
		NSLog(@"SELFUPDATE UNSUCCESSFUL");
	}*/
	
	
	return 0;
}

