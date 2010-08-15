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
#define MP_DEFAULT_PKG_PATH		@"/Library/Tcl"


#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include "BetterAuthorizationSampleLib.h"
#include <tcl.h>
#include "MPHelperCommon.h"

#include "MPHelperNotificationsProtocol.h"
#include "MPHelperNotificationsCommon.h"

#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/param.h>
#include <signal.h>


//According to the docs all I need is
//the file descriptor that MPNotifications
//obtained when creating the server socket
//I'll save that here when retrieving info.
//fromt he request dictionary
int notificationsFileDescriptor;
static int hasInstalledSignalToSocket = 0;
BOOL hasSetFileDescriptor = NO;
NSString * ipcFilePath;

#pragma mark -
#pragma mark ASL Logging 
@interface ASLLogger : NSObject {
	
}
+ (BOOL) logString:(NSString *)log;
@end

@implementation ASLLogger

+(BOOL) logString:(NSString *)log {
	//Initialize asl loggin asl logging stuff
	aslmsg logMsg = asl_new(ASL_TYPE_MSG) ;
	assert(logMsg != NULL);
	asl_set(logMsg, ASL_KEY_FACILITY, "com.apple.console");
	asl_set(logMsg, ASL_KEY_SENDER, "MPHelperTool");
	aslclient logClient = asl_open(NULL , NULL, ASL_OPT_STDERR);
	assert(logClient != NULL);
	
	int res = asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: %@" , log);
	asl_close(logClient);
	
	if (res == 0)
		return YES;
	return NO;
}

@end





#pragma mark -
/////////////////////////////////////////////////////////////////
#pragma mark ***** Notifications Connection Abstraction

// A ConnectionRef represents a connection from the client to the server. 
// The internals of this are opaque to external callers.  All operations on 
// a connection are done via the routines in this section.

enum {
    kConnectionStateMagic = 'LCCM'           // Local Client Connection Magic
};

typedef struct ConnectionState *  ConnectionRef;
// Pseudo-opaque reference to the connection.

typedef Boolean (*ConnectionCallbackProcPtr)(
											 ConnectionRef           conn, 
											 const PacketHeader *    packet, 
											 void *                  refCon
											 );
// When the client enables listening on a connection, it supplies a 
// function of this type as a callback.  We call this function in 
// the context of the runloop specified by the client when they enable 
// listening.
//
// conn is a reference to the connection.  It will not be NULL.
//
// packet is a pointer to the packet that arrived, or NULL if we've 
// detected that the connection to the server is broken.
//
// refCon is a value that the client specified when it registered this 
// callback.
//
// If the server sends you a bad packet, you can return false to 
// tell the connection management system to shut down the connection.

// ConnectionState is the structure used to track a single connection to 
// the server.  All fields after fSockFD are only relevant if the client 
// has enabled listening.

struct ConnectionState {
    OSType                      fMagic;             // kConnectionStateMagic
    int                         fSockFD;            // UNIX domain socket to server
    CFSocketRef                 fSockCF;            // CFSocket wrapper for the above
    CFRunLoopSourceRef          fRunLoopSource;     // runloop source for the above
    CFMutableDataRef            fBufferedPackets;   // buffer for incomplete packet data
    ConnectionCallbackProcPtr   fCallback;          // client's packet callback
    void *                      fCallbackRefCon;    // refCon for the above.
};

// Forward declarations.  See the comments associated with the function definition.

static void ConnectionShutdown(ConnectionRef conn);
static void ConnectionCloseInternal(ConnectionRef conn, Boolean sayGoodbye);

enum {
    kResultColumnWidth = 10
};

static int ConnectionSend(ConnectionRef conn, const PacketHeader *packet)
// Send a packet to the server.  Use this when you're not expecting a 
// reply.
//
// conn must be a valid connection
// packet must be a valid, ready-to-send, packet
// Returns an errno-style error code
{
    int     err;
    
    assert(conn != NULL);
    assert(conn->fSockFD != -1);            // connection must not be shut down
    // conn->fSockCF may or may not be NULL; it's OK to send a packet when listening 
    // because there's no reply; OTOH, you can't do an RPC while listening because 
    // an unsolicited packet might get mixed up with the RPC reply.
    
    assert(packet != NULL);
    assert(packet->fMagic == kPacketMagic);
    assert(packet->fSize >= sizeof(PacketHeader));
    
    // Simply send the packet down the socket.
    
    err = MoreUNIXWrite(conn->fSockFD, packet, packet->fSize, NULL);
    
    return err;
}



static int ConnectionOpen(ConnectionRef *connPtr)
// Opens a connection to the server.
//
// On entry, connPtr must not be NULL
// On entry, *connPtr must be NULL
// Returns an errno-style error code
// On success, *connPtr will not be NULL
// On error, *connPtr will be NULL
{
    int                 err;
    ConnectionRef       conn;
    Boolean             sayGoodbye;
    
    assert( connPtr != NULL);
    assert(*connPtr == NULL);
    
    sayGoodbye = false;
    
    // Allocate a ConnectionState structure and fill out some basic fields.
    
    err = 0;
    conn = (ConnectionRef) calloc(1, sizeof(*conn));
    if (conn == NULL) {
        err = ENOMEM;
    }
    if (err == 0) {
        conn->fMagic  = kConnectionStateMagic;
        
        // For clean up to work properly, we must make sure that, if 
        // the connection record is allocated successfully, we always 
        // set fSockFD to -1.  So, while the following line is redundant 
        // in the current code, it's present to press home this point.
		
        conn->fSockFD = -1;
    }
    
    // Create a UNIX domain socket and connect to the server. 
    
    if (err == 0) {
        conn->fSockFD = socket(AF_UNIX, SOCK_STREAM, 0);
        err = MoreUNIXErrno(conn->fSockFD);
    }
    if (err == 0) {
        struct sockaddr_un connReq;
		
        connReq.sun_len    = sizeof(connReq);
        connReq.sun_family = AF_UNIX;
        //strcpy(connReq.sun_path, kServerSocketPath);
		
//		char testPath [MAXPATHLEN];
//		strcpy(testPath, [ipcFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
		[ASLLogger logString:[NSString stringWithFormat:@"ipcFilePath is %@", ipcFilePath]];
//		const char * testPath = [ipcFilePath cStringUsingEncoding:NSUTF8StringEncoding];
		strcpy(connReq.sun_path, [ipcFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
		
        err = connect(conn->fSockFD, (struct sockaddr *) &connReq, SUN_LEN(&connReq));
        err = MoreUNIXErrno(err);
        
        sayGoodbye = (err == 0);
    }
    
    // Clean up.
    
    if (err != 0) {
        ConnectionCloseInternal(conn, sayGoodbye);
        conn = NULL;
    }
    *connPtr = conn;
    
    assert( (err == 0) == (*connPtr != NULL) );
    
    return err;
}

static int ConnectionRPC(
						 ConnectionRef           conn, 
						 const PacketHeader *    request, 
						 PacketHeader *          reply, 
						 size_t                  replySize
)
// Perform an RPC (Remote Procedure Call) with the server.  That is, send 
// the server a packet and wait for a reply.  You can only use this on 
// connections that are not in listening mode.
//
// conn must be a valid connection
//
// packet must be a valid, ready-to-send, packet
//
// reply and replySize specify a buffer where the reply packet is placed;
// reply size must not be NULL; replySize must not be less that the 
// packet header size (sizeof(PacketHeader)); if the reply packet is bigger 
// than replySize, the data that won't fit is discarded; you can detect this 
// by looking at reply->fSize
//
// Returns an errno-style error code
// On success, the buffer specified by reply and replySize will contain the 
// reply packet; on error, the contents of that buffer is invalid; also, 
// if this routine errors the connection is no longer useful (conn is still 
// valid, but you can't use it to transmit any more data)
{
    int     err;
    
    assert(conn != NULL);
    assert(conn->fSockFD != -1);            // connection must not be shut down
    assert(conn->fSockCF == NULL);          // RPC and listening are mutually exclusive
	// because unsolicited packet might get mixed up 
	// with the reply
	
    assert(request != NULL);
    assert(request->fMagic == kPacketMagic);
    assert(request->fSize >= sizeof(PacketHeader));
	
    assert(reply != NULL);
    assert(replySize >= sizeof(PacketHeader));
    
    // Send the request.
    
    err = ConnectionSend(conn, request);
    
    // Read and validate the reply header.
    
    if (err == 0) {
        err = MoreUNIXRead(conn->fSockFD, reply, sizeof(PacketHeader), NULL);
    }
    if ( (err == 0) && (reply->fMagic != kPacketMagic) ) {
        fprintf(stderr, "ConnectionRPC: Bad magic (%.4s).\n", (char *) &reply->fMagic);
        err = EINVAL;
    }
    if ( (err == 0) && (reply->fType != kPacketTypeReply) ) {
        fprintf(stderr, "ConnectionRPC: Type wrong (%.4s).\n", (char *) &reply->fType);
        err = EINVAL;
    }
    if ( (err == 0) && (reply->fID != request->fID) ) {
        fprintf(stderr, "ConnectionRPC: ID mismatch (%" PRId32 ").\n", reply->fID);
        err = EINVAL;
    }
    if ( (err == 0) && ( (reply->fSize < sizeof(PacketHeader)) || (reply->fSize > kPacketMaximumSize) ) ) {
        fprintf(stderr, "ConnectionRPC: Bogus packet size (%" PRIu32 ").\n", reply->fSize);
        err = EINVAL;
    }
	
    // Read the packet payload that will fit in the reply buffer.
    
    if ( (err == 0) && (reply->fSize > sizeof(PacketHeader)) ) {
        uint32_t  payloadToRead;
        
        if (reply->fSize > replySize) {
            payloadToRead = replySize;
        } else {
            payloadToRead = reply->fSize;
        }
        payloadToRead -= sizeof(PacketHeader);
        
        err = MoreUNIXRead(conn->fSockFD, ((char *) reply) + sizeof(PacketHeader), payloadToRead, NULL);
    }
	
    // Discard any remaining packet payload that will fit in the reply buffer.
    // The addition check in the next line is necessary to avoid the undefined behaviour 
    // of malloc(0) in the dependent block.
	
    if ( (err == 0) && (reply->fSize > replySize) ) {
        uint32_t    payloadToJunk;
        void *      junkBuf;
        
        payloadToJunk = reply->fSize - replySize;
        
        junkBuf = malloc(payloadToJunk);
        if (junkBuf == NULL) {
            err = ENOMEM;
        }
        
        if (err == 0) { 
            err = MoreUNIXRead(conn->fSockFD, junkBuf, payloadToJunk, NULL);
        }
        
        free(junkBuf);
    }
	
    // Any errors cause us to immediately shut down our connection because we 
    // we're no longer sure of the state of the channel (that is, did we leave 
    // half a packet stuck in the pipe).
    
    if (err != 0) {
        ConnectionShutdown(conn);
    }
    
    return err;
}


static void ConnectionShutdown(ConnectionRef conn)
// This routine shuts down down the connection to the server 
// without saying goodbye; it leaves conn valid.  This routine 
// is primarily used internally to the connection abstraction 
// where we notice that the connection has failed for some reason. 
// It's also called by the client after a successful quit RPC 
// because we know that the server has closed its end of the 
// connection.
//
// It's important to nil out the fields as we close them because 
// this routine is called if any messaging routine fails.  If it 
// doesn't nil out the fields, two bad things might happen:
//
// o When the connection is eventually closed, ConnectionCloseInternal 
//   will try to send a Goodbye, which fails triggering an assert.
//
// o If ConnectionShutdown is called twice on a particular connection 
//   (which happens a lot; this is a belts and braces implementation 
//   [that's "belts and suspenders" for the Americans reading this; 
//   ever wonder why Monty Python's lumberjacks sing about "suspenders 
//   and a bra"?; well look up "suspenders" in a non-American dictionary 
//   for a quiet chuckle :-] )
{
    int     junk;
    Boolean hadSockCF;
	
    assert(conn != NULL);
    
    conn->fCallback       = NULL;
    conn->fCallbackRefCon = NULL;
	
    if (conn->fRunLoopSource != NULL) {
        CFRunLoopSourceInvalidate(conn->fRunLoopSource);
        
        CFRelease(conn->fRunLoopSource);
        
        conn->fRunLoopSource = NULL;
    }
    
    // CFSocket will close conn->fSockFD when we invalidate conn->fSockCF, 
    // so we remember whether we did this so that, later on, we know 
    // whether to close the file descriptor ourselves.  We need an extra 
    // variable because we NULL out fSockCF as we release it, for the reason 
    // described above.
    
    hadSockCF = (conn->fSockCF != NULL);
    if (conn->fSockCF != NULL) {
        CFSocketInvalidate(conn->fSockCF);
        
        CFRelease(conn->fSockCF);
        
        conn->fSockCF = NULL;
    }
	
    if (conn->fBufferedPackets != NULL) {
        CFRelease(conn->fBufferedPackets);
        conn->fBufferedPackets = NULL;
    }
	
    if ( (conn->fSockFD != -1) && ! hadSockCF ) {
        junk = close(conn->fSockFD);
        assert(junk == 0);
    }
    // We always set fSockFD to -1 because either we've closed it or 
    // CFSocket has.
    conn->fSockFD = -1;
}


static void ConnectionCloseInternal(ConnectionRef conn, Boolean sayGoodbye)
// The core of ConnectionClose.  It's called by ConnectionClose 
// and by ConnectionOpen, if it fails for some reason.  This exists 
// as a separate routine so that we can add the sayGoodbye parameter, 
// which controls whether we send a goodbye packet to the server.  We 
// need this because we should always try to say goodbye if we're called 
// from ConnectionClose, but if we're called from ConnectionOpen we 
// should only try to say goodbye if we successfully connected the 
// socket.
//
// Regardless, the bulk of the work of this routine is done by 
// ConnectionShutdown.  This routine exists to a) say goodbye, if 
// necessary, and b) free the memory associated with the connection.
{
    int     junk;
    
    if (conn != NULL) {
        assert(conn->fMagic == kConnectionStateMagic);
		
        if ( (conn->fSockFD != -1) && sayGoodbye ) {
            PacketGoodbye   goodbye;
			
            InitPacketHeader(&goodbye.fHeader, kPacketTypeGoodbye, sizeof(goodbye), false);
            snprintf(goodbye.fMessage, sizeof(goodbye.fMessage), "Process %ld signing off", (long) getpid());
            
            junk = ConnectionSend(conn, &goodbye.fHeader);
            assert(junk == 0);
        }
        ConnectionShutdown(conn);
        
        free(conn);
    }
}

static void ConnectionClose(ConnectionRef conn)
// Closes the connection.  It's legal to pass conn as NULL, in which 
// case this does nothing (kinda like free'ing NULL).
{
    ConnectionCloseInternal(conn, true);
}



/////////////////////////////////////////////////////////////////
#pragma mark ***** Notifications Command Utilities 

static void SIGINTRunLoopCallback(const siginfo_t *sigInfo, void *refCon)
// This routine is called in response to a SIGINT signal. 
// It is not, however, a signal handler.  Rather, we 
// orchestrate to have it called from the runloop (via 
// the magic of InstallSignalToSocket).  It's purpose 
// is to stop the runloop when the user types ^C.
{
#pragma unused(sigInfo)
#pragma unused(refCon)
    
    // Stop the runloop.  Note that we can get a reference to the runloop by 
	// calling CFRunLoopGetCurrent because this is called from the runloop.
    
    CFRunLoopStop( CFRunLoopGetCurrent() );
    
    // Print a bonus newline to ensure that the next command prompt isn't 
    // printed on the same line as the echoed ^C.
    
    fprintf(stderr, "\n");
}


static void PrintResult(const char *command, int errNum, const char *arg)
// Prints the result of a command.  command is the name of the 
// command, errNum is the errno-style error number, and arg 
// (if not NULL) is the command argument.
{
    if (errNum == 0) {
        if (arg == NULL) {
            fprintf(stderr, "%*s\n", kResultColumnWidth, command);
        } else {
            fprintf(stderr, "%*s \"%s\"\n", kResultColumnWidth, command, arg);
        }
    } else {
        fprintf(stderr, "%*s failed with error %d\n", kResultColumnWidth, command, errNum);
    }
}




static void DoShout(ConnectionRef conn, const char *message, int * ret)
// Implements the "shout" command by sending a shout packet to the server. 
// Note that this is /not/ an RPC.
//
// The server responds to this packet by echoing it to each registered 
// listener.
{
    int         err;
	NSString * shoutString = [NSString stringWithFormat:@"Do Shout is passing %@", 
							  [NSString stringWithCString:message encoding:NSUTF8StringEncoding]];
	[ASLLogger logString:shoutString];
	
	
    PacketShout request;    
    InitPacketHeader(&request.fHeader, kPacketTypeShout, sizeof(request), false);
    snprintf(request.fMessage, sizeof(request.fMessage), "%s", message);
    err = ConnectionSend(conn, &request.fHeader);
    PrintResult("shout", err, message);
	*ret = err;
}

static void DoQuit(ConnectionRef conn, int * ret)
// Implements the "quit" command by doing a quit RPC with the server. 
// The server responds to this RPC by quitting.  Cleverly, it sends us 
// the RPC reply right before quitting.
{
    int         err;
    PacketQuit  request;
    PacketReply reply;
    
    InitPacketHeader(&request.fHeader, kPacketTypeQuit, sizeof(request), true);
    
    err = ConnectionRPC(conn, &request.fHeader, &reply.fHeader, sizeof(reply));
    if (err == 0) {
        err = reply.fErr;
		*ret = err;
    }
    if (err == 0) {
        // If the quit is successful, we shut down our end of the connection 
        // because we know that the server has shut down its end.
        ConnectionShutdown(conn);
    }
    [ASLLogger logString:@"DoQuit being called"];
	PrintResult("quit", err, NULL);
}

void initIPC (ConnectionRef iConn) {
	
	int             err = 0;
    //ConnectionRef   conn;
    iConn = NULL;
    
    // SIGPIPE is evil, so tell the system not to send it to us.
    if (err == 0) {
        err = MoreUNIXIgnoreSIGPIPE();
		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: err started out as ZERO %i", err);
		[ASLLogger logString:[NSString stringWithFormat:@"MPHelperTool: err started out as ZERO %i", err]];
		
    }
	
    // Organise to have SIGINT delivered to a runloop callback.
    if (err == 0 && hasInstalledSignalToSocket == 0) {
        sigset_t    justSIGINT;
        
        (void) sigemptyset(&justSIGINT);
        (void) sigaddset(&justSIGINT, SIGINT);
        
        err = InstallSignalToSocket(
									&justSIGINT,
									CFRunLoopGetCurrent(),
									kCFRunLoopDefaultMode,
									SIGINTRunLoopCallback,
									NULL
									);
        hasInstalledSignalToSocket = 1; 
		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: IgnoreSigPipe Successful");
		[ASLLogger logString:@"MPHelperTool: IgnoreSigPipe Successful"];
    }
    
    // Connect to the server.
    if (err == 0) {
        //err = ConnectionOpen(&iConn);
		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: Installed Signal to Socket!");
		[ASLLogger logString:@"MPHelperTool: Installed Signal to Socket!"];
    }
    
    
    
    if (err == 0) {
		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: calling DoShout");
		[ASLLogger logString:@"MPHelperTool: calling DoShout"];
		int i;
		DoShout(iConn, "Testing initIPC", &i);
	}
	else
		[ASLLogger logString:@"MPHelperTool: NOT calling DoShout"];
	//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: NOT calling DoShout");
	
}

#pragma mark -
#pragma mark Notifications Connection Abstraction

@interface NotificationsClient : NSObject
{
	ConnectionRef nConn;
	BOOL connected;
}

-(BOOL) initializeConnection;
-(BOOL) doShout:(NSString *)shout;
-(BOOL) closeConnection;
-(BOOL) connected;
@end

@implementation NotificationsClient

-(BOOL) initializeConnection {
	int             err = 0;
	nConn = NULL;
	
    // SIGPIPE is evil, so tell the system not to send it to us.
    if (err == 0) {
        err = MoreUNIXIgnoreSIGPIPE();
		[ASLLogger logString:[NSString stringWithFormat:@"MPHelperTool: err started out as ZERO %i", err]];
		
    }
	
    // Organise to have SIGINT delivered to a runloop callback.
    if (err == 0 && hasInstalledSignalToSocket == 0) {
        sigset_t    justSIGINT;
        
        (void) sigemptyset(&justSIGINT);
        (void) sigaddset(&justSIGINT, SIGINT);
        
        err = InstallSignalToSocket(
									&justSIGINT,
									CFRunLoopGetCurrent(),
									kCFRunLoopDefaultMode,
									SIGINTRunLoopCallback,
									NULL
									);
        hasInstalledSignalToSocket = 1;
		[ASLLogger logString:@"MPHelperTool: IgnoreSigPipe Successful"];
    }
    
    // Connect to the server.
    if (err == 0) {
        err = ConnectionOpen(&nConn);
		[ASLLogger logString:[NSString stringWithFormat:@"MPHelperTool: Installed Signal to Socket! %i", err]];
    }
	
	if (err == 0)
		connected = YES;
	else
		connected = NO;
	
	return connected;
}

-(BOOL) connected {
	return connected;
}
-(BOOL) doShout:(NSString *)shout {
	BOOL ret = YES;
	int v;
	
	if(nConn != NULL) {
		DoShout(nConn, [shout cStringUsingEncoding:NSUTF8StringEncoding], &v);
		if (v != 0) {
			ret = NO;
		}
	}
	else 
		ret = NO;
	
	return ret;
}

-(BOOL) closeConnection {
	int v;
	BOOL ret = YES;
	if(nConn != NULL) {
		DoQuit(nConn, &v);
		if ( v != 0) {
			ret = NO;
		}
	}
	else
		ret = NO;
	
	return ret;
}


@end



# pragma mark -

#pragma mark Tcl Commands
NotificationsClient * notifier = nil;
//For now we just log to Console ... soon we will be doing fully fledged IPC
int SimpleLog_Command 
(
 ClientData clientData, 
 Tcl_Interp *interpreter, 
 int objc, 
 Tcl_Obj *CONST objv[]
) 
{
	
	int returnCode = TCL_ERROR;
	NSMutableString * data;
	
	++objv, --objc;
	
	if (objc) {
		int tclCount;
		int tclResult;
		const char **tclElements;
		
		
		tclResult = Tcl_SplitList(interpreter, Tcl_GetString(*objv), &tclCount, &tclElements);
		
		
		if (tclResult == TCL_OK) {
			if (tclCount > 0) {
				data = [NSMutableString stringWithUTF8String:tclElements[0]];
				[data appendString:MPSEPARATOR];
				
				if(tclCount > 1 && tclElements[1]) {
					[data appendString:[NSString stringWithUTF8String:tclElements[1]]];
					[data appendString:MPSEPARATOR];
				}
				else {
					[data appendString:@"None"];
					[data appendString:MPSEPARATOR];
				}
				
				if(tclCount > 2 && tclElements[2]) {
					[data appendString:[NSString stringWithUTF8String:tclElements[2]]];
					[data appendString:MPSEPARATOR];
				}
				else {
					[data appendString:@"None"];
					[data appendString:MPSEPARATOR];
				}
			}
			else {
				data = [NSMutableString stringWithFormat:@"None%@None%@None%@", MPSEPARATOR, MPSEPARATOR, MPSEPARATOR ];
			}
		}
	}
		
		//Now get the actual message
		++objv; --objc;
		if (objc) {
			[data appendString:[NSString stringWithUTF8String:Tcl_GetString(*objv)]];
		}
		else {
			[data appendString:@"None"];
		}
		
		if (data != nil) {
			//[ASLLogger logString:data];
			if (notifier != nil && [notifier connected]) {
				if([notifier doShout:data]) {
					returnCode = TCL_OK;
					[ASLLogger logString:@"DoShout successful"];
				}
				else
					[ASLLogger logString:@"DoShout unsuccessful"];
			}
			else
				[ASLLogger logString:[NSString stringWithFormat:@"notifier didn't connect has value %@", notifier]];
		}
	
	return returnCode;
}




#pragma mark -





/////////////////////////////////////////////////////////////////
#pragma mark ***** Tool Infrastructure


static OSStatus DoEvaluateTclString 
(
 AuthorizationRef			auth,
 const void *				userData,
 CFDictionaryRef			request,
 CFMutableDictionaryRef		response,
 aslclient					asl,
 aslmsg						aslMsg
 )
{
	
	OSStatus		retval = noErr;
	
	
	//Pre conditions
	assert(auth != NULL);
	//userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
	//asl may be null
	//aslMsg may be null
	
	//Get the ipc file path
	ipcFilePath = [[NSString alloc] initWithString:(NSString *) (CFStringRef)CFDictionaryGetValue(request, CFSTR(kServerFileSocketPath))];
	if (ipcFilePath == nil) {
		retval = coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("SocketServerFilePath"), (CFStringRef)ipcFilePath);
	[notifier initializeConnection];
	
	
	//Get the string that was passed in the request dictionary
	NSString *  tclCmd = (NSString *) (CFStringRef)CFDictionaryGetValue(request, CFSTR(kTclStringToBeEvaluated));
	if (tclCmd == nil) {
		retval = coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("TclCommandInput"), (CFStringRef)tclCmd);
	
	
	//Create Tcl Interpreter 
	Tcl_Interp * interpreter = Tcl_CreateInterp();
	if(interpreter == NULL) {
		NSLog(@"Error in Tcl_CreateInterp, aborting.");
		//For Debugging
		CFDictionaryAddValue(response, CFSTR("TclInterpreterCreate"), CFSTR("NO"));
		retval =  coreFoundationUnknownErr;
	}
	else {//For Debugging
		CFDictionaryAddValue(response, CFSTR("TclInterpreterCreate"), CFSTR("YES"));
	}
	
	
	//Initialize Tcl Interpreter
	if(Tcl_Init(interpreter) == TCL_ERROR) {
		NSLog(@"Error in Tcl_Init: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("TclInterpreterInit"), CFSTR("NO"));
	}
	else {//For Dbg.
		CFDictionaryAddValue(response, CFSTR("TclInterpreterInit"), CFSTR("YES"));
	}
	
	
	
	//Get the tcl Interpreter pkg path
	NSString * tclPkgPath = (NSString *) (CFStringRef) CFDictionaryGetValue(request, CFSTR(kTclInterpreterInitPath));
	if (tclPkgPath == nil) {
		retval == coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("TclPkgPath"), (CFStringRef)tclPkgPath);
	
	//Load macports1.0 package
	NSString * mport_fastload = [[@"source [file join \"" stringByAppendingString:tclPkgPath]
								 stringByAppendingString:@"\" macports1.0 macports_fastload.tcl]"];
	if(Tcl_Eval(interpreter, [mport_fastload UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile macports_fastload.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("MPFastload"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("MPFastload"), CFSTR("YES"));
	}
	
	
	//Add simplelog tcl command
	Tcl_CreateObjCommand(interpreter, "simplelog", SimpleLog_Command, NULL, NULL);
	if (Tcl_PkgProvide(interpreter, "simplelog", "1.0") != TCL_OK) {
		NSLog(@"Error in Tcl_PkgProvide: %s", Tcl_GetStringResult(interpreter));
		retval = coreFoundationUnknownErr;
		//For Dbg
		CFDictionaryAddValue(response, CFSTR("simplelog"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("simplelog"), CFSTR("YES"));
	}
	
	
	//Get path for and load interpInit.tcl file to Tcl Interpreter
	NSString * interpInitFilePath = (NSString *) (CFStringRef) CFDictionaryGetValue(request, CFSTR(kInterpInitFilePath));
	if (interpInitFilePath == nil) {
		CFDictionaryAddValue(response, CFSTR("interpInitFilePath"), CFSTR("NO"));
		retval = coreFoundationUnknownErr;
	}
	else
		CFDictionaryAddValue(response, CFSTR("interpInitFilePath"), (CFStringRef)interpInitFilePath);
	if( Tcl_EvalFile(interpreter, [interpInitFilePath UTF8String]) == TCL_ERROR) {
		NSLog(@"Error in Tcl_EvalFile init.tcl: %s", Tcl_GetStringResult(interpreter));
		Tcl_DeleteInterp(interpreter);
		retval = coreFoundationUnknownErr;
		CFDictionaryAddValue(response, CFSTR("interpInit.tcl Evaluation"), CFSTR("NO"));
	}
	else {
		CFDictionaryAddValue(response, CFSTR("interpInit.tcl Evaluation"), CFSTR("YES"));
	}
	
	
	///Evaluate String and set return string value
	NSString * result;
	int retCode = Tcl_Eval(interpreter, [tclCmd UTF8String]);
	NSNumber * retNum = [NSNumber numberWithInt:retCode];
	if(  retCode == TCL_ERROR ) {
		//Do some error handling
		retval = coreFoundationUnknownErr;
		result = [@"TCL COMMAND EXECUTION FAILED BOO!:" 
				  stringByAppendingString:[NSString stringWithUTF8String:Tcl_GetStringResult(interpreter)]];
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), (CFStringRef)result);
		
		//Set the Tcl return code
		CFDictionaryAddValue(response, CFSTR(kTclReturnCode), (CFNumberRef)retNum);
	}
	else {
		retval = noErr;
		result = [@"TCL COMMAND EXECUTION SUCCEEDED YAAY!:" 
				  stringByAppendingString:[NSString stringWithUTF8String:Tcl_GetStringResult(interpreter)]];
		CFDictionaryAddValue(response, CFSTR(kTclStringEvaluationResult), (CFStringRef)result);
		
		//Set the Tcl return code
		CFDictionaryAddValue(response, CFSTR(kTclReturnCode), (CFNumberRef)retNum);
	}
	
	
	assert(response != NULL);
	
	return retval;
}


/*
 IMPORTANT
 ---------
 This array must be exactly parallel to the kMPHelperCommandSet array 
 in "MPHelperCommon.c".
 */
static const BASCommandProc kMPHelperCommandProcs[] = {
DoEvaluateTclString,	
NULL
};

int main(int argc, char const * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//assert(logClient != NULL);
	
//	
//	int             err = 0;
//    ConnectionRef   conn;
//    conn = NULL;
//    
//    // SIGPIPE is evil, so tell the system not to send it to us.
//    if (err == 0) {
//        err = MoreUNIXIgnoreSIGPIPE();
//		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: err started out as ZERO %i", err);
//		[ASLLogger logString:[NSString stringWithFormat:@"MPHelperTool: err started out as ZERO %i", err]];
//		
//    }
//	
//    // Organise to have SIGINT delivered to a runloop callback.
//    if (err == 0) {
//        sigset_t    justSIGINT;
//        
//        (void) sigemptyset(&justSIGINT);
//        (void) sigaddset(&justSIGINT, SIGINT);
//        
//        err = InstallSignalToSocket(
//									&justSIGINT,
//									CFRunLoopGetCurrent(),
//									kCFRunLoopDefaultMode,
//									SIGINTRunLoopCallback,
//									NULL
//									);
//		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: IgnoreSigPipe Successful");
//		[ASLLogger logString:@"MPHelperTool: IgnoreSigPipe Successful"];
//    }
//    
//    // Connect to the server.
//    if (err == 0) {
//        err = ConnectionOpen(&conn);
//		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: Installed Signal to Socket!");
//		[ASLLogger logString:@"MPHelperTool: Installed Signal to Socket!"];
//    }
//    
//    
//    
//    if (err == 0) {
//		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: calling DoShout");
//		[ASLLogger logString:@"MPHelperTool: calling DoShout"];
//		
//		DoShout(conn, "Testing MPHelperTool IPC");
//	}
//	else
//		[ASLLogger logString:@"MPHelperTool: NOT calling DoShout"];
//		//asl_NSLog(logClient , logMsg, ASL_LEVEL_DEBUG, @"MPHelperTool: NOT calling DoShout");
	
	
	//initIPC(globalConn);
	
	//if(!globalConnInitialized){
//		initIPC(globalConn);
//		globalConnInitialized = YES;
//	}
//	
	
	notifier = [[NotificationsClient alloc] init];
	
	
	int result = BASHelperToolMain(kMPHelperCommandSet, kMPHelperCommandProcs);
	
	// Clean up.
	//DoQuit(globalConn);
   // ConnectionClose(globalConn);
	//asl_close(logClient);
	
	[notifier closeConnection];
	[notifier release];
	[ipcFilePath release];
	
	[pool release];
	
	return result;
}