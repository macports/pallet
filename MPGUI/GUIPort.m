//
//  GUIPort.m
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/12/09.
//  Copyright 2009 UNAM. All rights reserved.
//

#import "GUIPort.h"


@implementation GUIPort

@synthesize state;

- (id) initWithMPPort:(MPPort*) mpport{
    port = mpport;
    return self;
}

- (NSString*) description {
    return [port valueForKey:@"description"];
}

- (id) valueForUndefinedKey:(NSString*) key{
    return [port valueForKey:key];
}

@end
