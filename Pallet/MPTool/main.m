#import <Foundation/Foundation.h>
#import "MPAgent.h"
#include <sys/types.h>
#include <unistd.h>

int main(int argc, const char *argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    MPAgent *agent;

    setuid(0);
    
    agent = [[MPAgent alloc] init];

    [[NSRunLoop currentRunLoop] run];

    [pool release];
    return 0;
        
}

