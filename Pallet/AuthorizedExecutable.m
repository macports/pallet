/*
 File: AuthorizedExecutable.m

 Created by David Love on Thu Jul 18 2002.
 Copyright (c) 2002 Cashmere Software, Inc.
 Released to Steven J. Burr on August 21, 2002, under the Gnu General Public License.

 See the header file, AuthorizedExecutable.h for more information on the license.

*/

#import <Security/AuthorizationTags.h>
#import "AuthorizedExecutable.h"

@implementation AuthorizedExecutable

// This needs to be initialized with the full path to the Launcher
// executable (which should be setuid root).  Note that this is
// different from the executable you want eventually run.  That
// executable will be specified as the first entry in the arguments
// array.
//
- (id)initWithExecutable:(NSString*)exe
{
    if (self = [super init])
    {
        NSMutableArray* args = [[NSMutableArray alloc] init];
        [self setArguments:args];
        [args release];
		NSDictionary *env = [[NSDictionary alloc] init];
		[self setEnvironment:env];
		[env release];
        output = [[NSMutableString alloc] init];
        [output retain];
        [self setAuthExecutable:exe];
        [self setMustBeAuthorized:false];
    }
    return self;
}


// self-explanatory
//
-(void)dealloc
{
    [self stop];
    [self setAuthExecutable:nil];
    [self setArguments:nil];
	[self setEnvironment:nil];
    [output release];
	[super dealloc];
}


// The command and arguments you want to run.  This is passed
// directly to NSTask.  The first entry is the command you want
// to run.  Any other entries are the options you want passed 
// to the command.  Note that if an option has an associated
// argument (-r foo), they must be specified in the array as
// *two* entries ('-r' and 'foo'), not one.
//
-(NSMutableArray*)arguments
{
    return arguments;
}

-(void)setArguments:(NSMutableArray*)args
{
    [args retain];
    [arguments release];
    arguments = args;
}

-(NSDictionary *)environment
{
	return environment;
}

-(void)setEnvironment:(NSDictionary *)env
{
	[env retain];
	[environment release];
	environment = env;
}


// Helper routine.  Both authorize and authorizedWithQuery call
// this routine to check the authorization.  They just use different
// flags to determine if the 'authorization dialog' should be 
// displayed.
//
-(bool)checkAuthorizationWithFlags:(AuthorizationFlags)flags
{
    AuthorizationRights rights;
    AuthorizationItem items[1];
    OSStatus err = errAuthorizationSuccess;

    if (! [self isExecutable])
    {
        return false;
    }

    if (authorizationRef == NULL)
    {
        err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
                                  kAuthorizationFlagDefaults, &authorizationRef);
     }

    if (err == errAuthorizationSuccess)
    {
        // There should be one item in the AuthorizationItems array for each
        // right you want to acquire.
        // The data in the value and valueLength is dependent on which right you
        // want to acquire.
        // For the right to execute tools as root, kAuthorizationRightExecute,
        // they should hold a pointer to a C string containing the path to
        // the tool you want to execute, and the length of the C string path.
        // There needs to be one item for each tool you want to execute.
		items[0].name = "org.macports.pallet	";
		items[0].value = 0;
		items[0].valueLength = 0;		
        items[0].flags = 0;
        rights.count=1;
        rights.items = items;
        // Since we've specified kAuthorizationFlagExtendRights and
        // haven't specified kAuthorizationFlagInteractionAllowed, if the
        // user isn't currently authorized to execute tools as root,
        // they won't be asked for a password and err will indicate
        // an authorization failure.
        err = AuthorizationCopyRights(authorizationRef,&rights,
                                      kAuthorizationEmptyEnvironment,
                                      flags, NULL);
    }
	NSLog(@"Authorization Success: %@", [NSNumber numberWithInt:err]);
    return errAuthorizationSuccess==err;
}


// attempt to authorize the user without displaying the authorization dialog.
//
-(bool)authorize
{
    return [self checkAuthorizationWithFlags:kAuthorizationFlagExtendRights];
}


// attempt to authorize the user, displaying the authorization dialog
// if necessary.
//
-(bool)authorizeWithQuery
{
    return [self checkAuthorizationWithFlags:kAuthorizationFlagExtendRights| kAuthorizationFlagInteractionAllowed];
}

// accessor for the Launcher program
//
- (NSString*)authExecutable
{
    return authExecutable;
}

// Helper routine which converts the current authorizionRef to its 
// external form.  The external form will eventually get piped
// to the Launcher.
//
-(bool)fillExternalAuthorizationForm:(AuthorizationExternalForm*)extAuth
{
    bool result = false;
    if (authorizationRef)
    {
        result = errAuthorizationSuccess != AuthorizationMakeExternalForm(authorizationRef, extAuth);
    }
    return result;
}

// self-explanatory
//
-(bool)isAuthorized
{
    return [self authorize];
}

// Determine if the Launcher exists and is executable.
//
-(bool)isExecutable
{
    NSString* exe = [self authExecutable];
    return exe != nil && [[NSFileManager defaultManager] isExecutableFileAtPath:exe];
}

-(bool)mustBeAuthorized
{
    return mustBeAuthorized;
}


// Call this with 'true' if the user must be authorized before
// running the command.  The default value for this is false
//
-(void)setMustBeAuthorized:(bool)b
{
    mustBeAuthorized = b;
}

// deprecated (just instantiate a new AuthorizedExecutable object if you
// want a different launcher).
//
-(void)setAuthExecutable:(NSString*)exe
{
    [self unAuthorize];
    [exe retain];
    [authExecutable release];
    authExecutable = exe;
}

// Free any existing authorization.  This sets the user to an unauthorized
// state.
//
-(void)unAuthorize
{
    if (authorizationRef != NULL)
    {
        AuthorizationFree(authorizationRef,kAuthorizationFlagDestroyRights);
        authorizationRef = NULL;
    }
}

-(void)setDelegate:(id)dgate
{
    [dgate retain];
    [delegate release];
    delegate = dgate;
}

-(id)delegate
{
    return delegate;
}


// This saves the output of the command in the output string.  A
// delegate should implement captureOutput:forExecutable to receive
// the command's output
-(void)log:(NSString*)str
{
    if ([[self delegate] respondsToSelector:@selector(captureOutput:forExecutable:)])
    {
        [[self delegate] performSelector:@selector(captureOutput:forExecutable:) 
						 withObject:str withObject:self];
    }
    else
    {
        [output replaceCharactersInRange:NSMakeRange([output length], 0) 
				withString:str];
    }
}

// This saves capture the program's stdout and either passes it to a delegate, if assigned,
// or to the log method.
//
-(void)logStdOut:(NSString*)str
{
    if ([[self delegate] respondsToSelector:@selector(captureStdOut:forExecutable:)])
    {
        [[self delegate] performSelector:@selector(captureStdOut:forExecutable:) 
							withObject:str 
							withObject:self];
    }
    else
    {
        [self log:str];
    }
}

// This saves capture the program's stderr and either passes it to a delegate, if assigned,
// or to the log method.
//
-(void)logStdErr:(NSString*)str
{
    if ([[self delegate] respondsToSelector:@selector(captureStdErr:forExecutable:)])
    {
        [[self delegate] performSelector:@selector(captureStdErr:forExecutable:) 
							withObject:str 
							withObject:self];
    }
    else
    {
        [self log:str];
    }
}

-(void)writeData:(NSData*)data
{
    if ([self isRunning])
    {
        [stdinHandle writeData:data];
    }
}

-(void)writeToStdin:(NSString*)str
{
    [self writeData:[str dataUsingEncoding:NSASCIIStringEncoding]];
}

// Internal routines used to capture output asynchronously.
// If a delegate overrides the executableFinished:withStatus method,
// it will be called when the command exits.
//
//  (void)executableFinished:(AuthorizedExecutable*)exe withStatus:(int)status;
//

//Helper method
-(NSString *)stringFromOutputData:(NSData *)data
{
	NSString *outputString;
	
	NS_DURING
		outputString = [NSString stringWithCString:[data bytes] length:[data length]];
		return outputString;	
	NS_HANDLER
		return @"WARNING:  Unable to decode output for display.\n";
	NS_ENDHANDLER
	;
}

-(void)captureStdOut:(NSNotification*)notification
{
    NSData *inData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (inData == nil || [inData length] == 0)
    {
        [task waitUntilExit];
        [self stop];
    }
    else
    {
        [self logStdOut:[NSString stringWithCString:[inData bytes] 
			    length:[inData length]]];
        [stdoutHandle readInBackgroundAndNotify];
    }
}

// Internal routine used to capture stderr asynchronously.
//
-(void)captureStdErr:(NSNotification*)notification
{
    NSData *inData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (inData != nil && [inData length] != 0)
    {
        [self logStdErr:[NSString stringWithCString:[inData bytes]
                                             length:[inData length]]];
        [stderrHandle readInBackgroundAndNotify];
    }
}

// task status
//
- (bool)isRunning
{
    return [task isRunning];
}


// Call this to start the command.  If the command is already running,
// this is a no-op.
- (void)start
{
    if (! [task isRunning])
    {
        AuthorizationExternalForm extAuth;
        OSStatus err;
        NSPipe *stdinPipe = nil;
        NSPipe *stdoutPipe = nil;
        //NSPipe *stderrPipe = nil;

        [output setString:@""];

        if (! [self isExecutable])
        {
            [self log:
                NSLocalizedString(@"I can't find the tool I use to run an authorized command. You'll need to reinstall this application\n",@"This warning is issued if the user tries to start this task and the Launcher can't be found or isn't executable")];
			return;
        }

		if ([self mustBeAuthorized] && ! [self isAuthorized])
		{
			[self log:
				NSLocalizedString(@"You must authorize yourself before you can run this command.\n",@"This warning is issued if the user tries to start this task when the mustBeAuthorized flag is set and the user isn't authorized")];
			return;
		}
        err = AuthorizationMakeExternalForm(authorizationRef, &extAuth);
        if (err != errAuthorizationSuccess)
        {
            [self log:[NSString stringWithFormat:@"TODO: Unknown error in AuthorizationMakeExternalForm: (%d)\n", err]];
            return;
        }

        NS_DURING
            stdoutPipe = [NSPipe pipe];
            stdinPipe = [NSPipe pipe];
            //stderrPipe = [NSPipe pipe];

            stdinHandle = [stdinPipe fileHandleForWriting];
            [stdinHandle retain];
            stdoutHandle = [stdoutPipe fileHandleForReading];
            [stdoutHandle retain];
            //stderrHandle = [stderrPipe fileHandleForReading];
            //[stderrHandle retain];

            [[NSNotificationCenter defaultCenter] 
						addObserver:self 
						selector:@selector(captureStdOut:)
						name:NSFileHandleReadCompletionNotification
						object:stdoutHandle];
#ifdef UNDEF
            [[NSNotificationCenter defaultCenter] 
						addObserver:self selector:@selector(captureStdErr:)
						name:NSFileHandleReadCompletionNotification
						object:stderrHandle];
#endif
            [stdoutHandle readInBackgroundAndNotify];
            //[stderrHandle readInBackgroundAndNotify];

            task = [[NSTask alloc] init];
            [task retain];
            [task setStandardOutput:stdoutPipe];
            [task setStandardInput:stdinPipe];
			//my change:
			[task setStandardError:stdoutPipe];
            //[task setStandardError:stderrPipe];

            [task setLaunchPath:[self authExecutable]];
			NSLog(@"Launching %@", [self authExecutable]);
            [task setArguments:[self arguments]];
			NSLog(@"Setting arguments");
			[task setEnvironment:[self environment]];
			NSLog(@"Setting environment");
            [task launch];
			NSLog(@"Launched Launcher");
            [self writeData:[NSData dataWithBytes:&extAuth 
				  length:sizeof(AuthorizationExternalForm)]];

        NS_HANDLER
            [self log:[NSString stringWithFormat:@"Failed while trying to launch helper program"]];
            [self stop];
        NS_ENDHANDLER
        ;
    }
}

// This terminates the running process, if necessary, and cleans up 
// any related objects.
//
- (void)stop
{
	int status;

    if (stdoutHandle)
    {
        [[NSNotificationCenter defaultCenter] 
			removeObserver:self
			name:NSFileHandleReadCompletionNotification
			object:stdoutHandle];
    }
    if (stderrHandle)
    {
        [[NSNotificationCenter defaultCenter] 
			removeObserver:self
			name:NSFileHandleReadCompletionNotification
			object:stderrHandle];
    }
    if ([task isRunning])
    {
		NSLog(@"Task terminated");
        [task terminate];
		[task waitUntilExit];
    }
	status = [task terminationStatus];
    [task release];
	[stdinHandle closeFile];
	[stdoutHandle closeFile];
	//[stderrHandle closeFile];
    [stdinHandle release];
    [stdoutHandle release];
    //[stderrHandle release];
    task = nil;
    stdoutHandle = nil;
    stdinHandle = nil;
    //stderrHandle = nil;
	if ([[self delegate]
				respondsToSelector:@selector(executableFinished:withStatus:)])
	{
		[[self delegate]
				performSelector:@selector(executableFinished:withStatus:)
					 withObject:self
					 withObject:[NSNumber numberWithInt:status]];
	}	
}


@end
