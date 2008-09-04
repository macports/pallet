/*
 *	$Id$
 *	MacPorts.Framework
 *
 *	Authors:
 * 	Randall H. Wood <rhwood@macports.org>
 *
 *	Copyright (c) 2007 Randall H. Wood <rhwood@macports.org>
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

/*!
 @header 
 MPMacPorts represents an installation of MacPorts on a user's system. A user can have 
 multiple MacPorts installations in different locations.
 */

#import <Cocoa/Cocoa.h>
#import "MPInterpreter.h"
#import "MPPort.h"


#define MPPortsAll	@".+"



/*!
 @class MPMacPorts
 @abstract Object representation of the MacPorts system
 @discussion This class represents a single instance of the MacPorts installation system on a user's machine.
 There is usually only one instance of this per machine, even though there might be more than one in some
 cases.
 
 Available Delegate methods:
 Delegates of this class may choose to implement one of the following method
 - (AuthorizationRef) getAuthorizationRef;
	getAuthorizationRef should return an AuthorizationRef structure which will be used for
	performing privileged MacPorts operations. Framework clients should do all necessary preauthorization
	before returning the AuthorizationRef structure, in addition, Framework clients are
	responsible for freeing the memory associated with the passed AuthorizationRef structure.
 */
@interface MPMacPorts : NSObject {

	MPInterpreter *interpreter;

	NSString *prefix;
	NSArray *sources;
	NSString *version;
	
	id macportsDelegate;
	BOOL authorizationMode;
	
}

/*!
 @brief Returns an MPMacPorts object that represents the MacPorts system on user's machine.
 */
+ (MPMacPorts *)sharedInstance;

//Names of messages below are subject to change
+ (MPMacPorts *)sharedInstanceWithPkgPath:(NSString *)path;
- (id) initWithPkgPath:(NSString *)path;

/*!
 @brief Synchronizes the ports tree without checking for upgrades to the MacPorts base.
 */
- (id)sync:(NSError **)sError;
/*!
 @brief Synchronizes the ports tree and checks for upgrades to MacPorts base.
 @discussion The selfupdate port command is available only on Mac OS X systems.
 */
- (void)selfUpdate:(NSError **)sError;



/*!
 @brief Returns an NSDictionary of ports. Calls [self search:query caseSensiitve:YES].   
 @param query An NSString containing name or partial name of port being searched. 
 @discussion The keys are NSString names of the ports whilst the values are the respective MPPort objects.
 Possible search style options are are regexp, exact and glob.
 */
- (NSDictionary *)search:(NSString *)query;
/*!
 @brief Returns an NSDictionary of ports. Calls [self search:query caseSensitive:sensitivity matchStyle:\@"regex"].  
 @param query An NSString containing name (full or parital) of port being searched.
 @param sensitivity A Boolean value indicating whether or not the search should be case sensitive
 @discussion  The keys are NSString names of the ports whilst the values are the respective MPPort objects.
 Possible search style options are are regexp, exact and glob.
 */
- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)sensitivity;
/*!
 @brief Returns an NSDictionary of ports. Calls [self search:query caseSensitive:sensitivity matchStyle:style field:\@"name"].  
 @param query An NSString containing name (full or parital) of port being searched.
 @param sensitivity A Boolean value indicating whether or not the search should be case sensitive
 @param style Search style for query
 @discussion  The keys are NSString names of the ports whilst the values are the respective MPPort objects.
 Possible search style options are are regexp, exact and glob.
 */
- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)sensitivity matchStyle:(NSString *)style;
/*!
 @brief Returns an NSDictionary of ports  
 @param query An NSString containing name (full or parital) of port being searched.
 @param sensitivity A Boolean value indicating whether or not the search should be case sensitive
 @param style Search style for query
 @param fieldName Field for port query
 @discussion  The keys are NSString names of the ports whilst the values are the respective MPPort objects.
 Possible search style options are are regexp, exact and glob.
 */
- (NSDictionary *)search:(NSString *)query caseSensitive:(BOOL)sensitivity matchStyle:(NSString *)style field:(NSString *)fieldName;


/*!
 @brief Returns an NSArray of NSString port names that a port depends on
 @param port The MPPort whose dependecies is being sought
 */
- (NSArray *)depends:(MPPort *)port;


/*!
 @brief Executes specific target of given MPPort
 @param port The MPPort whose target will be executed
 @param target The NSString representing a given target
 @param options An NSArray of NSStrings of options for executing this target
 @param variants An NSArray of NSStrings of variants for executing this target 
 @Discussion See -exec: withOptions: withVariants: in @link //apple_ref/doc/header/MPPort.h MPPort @/link for discussion
 of this method.
 */
- (void)exec:(MPPort *)port withTarget:(NSString *)target options:(NSArray *)options variants:(NSArray *)variants error:(NSError **)execError;

/*!
 @brief Returns the NSString path to the directory where ports are installed.
 */
- (NSString *)prefix;

/*!
 @brief Returns an NSArray of NSStrings for the paths to MacPorts sources or port trees
 @param refresh A boolean indicating whether or not to refresh the NSArray of port trees
 @Discussion A refresh value of YES will refresh the ports tree whilst a value of NO will not refresh
 the tree.
 */
- (NSArray *)sources:(BOOL)refresh;
/*!
 @brief Returns an NSArray of NSStrings of paths to various port trees enabled on User's system
 @Discussion These file paths are listed in opt/local/etc/macports/sources.conf. Each port tree
 contains the different files for each port.
 */
- (NSArray *)sources;

/*!
 @brief Returns the NSURL of the portIndex file on this MacPorts system for a given ports tree
 @param source An NSString containing the file path to the ports tree
 @Discussion The PortIndex is a list of serialized Tcl key-value lists, one list
 per line. This is where ports are searched for.
 */
- (NSURL *)pathToPortIndex:(NSString *)source;

/*!
 @brief Returns an NSString indicating the version of the currently running MacPorts system
 */
- (NSString *)version;


/*!
 @brief Returns the delegate for this MPMacPorts object
 @Discussion Delegates of MPMacPorts may opt to implement -setAuthoriztionRef: .
 See (add link here to class discussion section) for more details.
 */
- (id)delegate;

/*!
 @brief Sets the delegate for this MPMacPorts object
 @param aDelegate The object to be set as the delegate
 @Discussion Delegates of MPMacPorts may opt to implement -setAuthoriztionRef: .
 See (add link here to class discussion section) for more details.
 */
- (void)setDelegate:(id)aDelegate;

/*!
 @brief Determines whether certain port operations require privileges before exection
 @param mode A YES value will require privileges whereas a NO value will not require privileges.
 @Discussion Use this method to indicate whether port operations should be
 run with privilieges. The default behavior is to not run these port operations with
 privileges. Operations affected by this setting include -sync, -selfUpdate, all variants
 of the -exec method and all of MPPort's port manipulation methods.
 */
-(void) setAuthorizationMode:(BOOL)mode;

/*! Returns a BOOL that indicates whether or not port operations are to be run with privileges
 @Discussion You can use this method in conjuction with -setAuthorizationMode: to set and unset
 the authorization mode for this MPMacPorts object. A return value of YES means that the -sync,
 -selfUpdate, all variants of the -exec method and all of MPPort's port manipulation methods 
 require privileges;a return value of NO indicates that they don't.
 */
-(BOOL) authorizationMode;


//Notifications stuff for private use and testing purposes
-(void)registerForLocalNotifications;
-(void)respondToLocalNotification:(NSNotification *) notification;

@end
