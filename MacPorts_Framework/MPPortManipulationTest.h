//
//  MPPortManipulationTest.h
//  MacPorts.Framework
//
//  Created by George  Armah on 8/14/08.
//  Copyright 2008 Lafayette College. All rights reserved.
//


//This test class is very important. It is going to test all the basic
//important port manipuation routines e.g. searching, installing, activation,
//deactivation, finding dependencies etc. etc.


#import <SenTestingKit/SenTestingKit.h>
#import <MacPorts/MacPorts.h>

@interface MPPortManipulationTest : SenTestCase {
	MPMacPorts * mainPort;
}

-(void) testSimpleManipulation;
@end
