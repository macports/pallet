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
 The MPPort class is an object representation of a port
 */

#import <Cocoa/Cocoa.h>
#import "MPInterpreter.h"
#import "MPMutableDictionary.h"
#import "MPReceipt.h"
#import "MPRegistry.h"




#define	MPPortStateUnknown		0
#define MPPortStateLearnState	1

#define MPPortStateActive		2
#define MPPortStateInstalled	3
#define MPPortStateOutdated		4
#define MPPortStateNotInstalled 5

#define MPPortWillExecuteTarget	@"org.macports.framework.port.willExecuteTarget"
#define MPPortDidExecuteTarget	@"org.macports.framework.port.didExecuteTarget"
/*!
 @class MPPort
 @abstract	A representation of a port.
 */
@interface MPPort : MPMutableDictionary {
}

/*!
 @brief Initializes this port with a MPPortStateUnkown state
 @discussion Calls [self initWithCapacity:15]
 */
- (id)init;
/*!
 @brief Initializes this port with a MPPortStateUnkown state
 @param numItems The number of items to be stored with this port
 */
- (id)initWithCapacity:(unsigned)numItems;
/*!
 @brief Initializes this port with an NSString derived from a Tcl list
 @param string The NSString object used to initialize this MPPort object
 @discussion The Tcl list is usually obtained from doing a search query for some
 particular port.
 
 IS THIS METHOD JUST FOR INTERNAL USE? IT LOOKS LIKE IT ... ASK RANDALL ABOUT THAT
 */
- (id)initWithTclListAsString:(NSString *)string;

/*!
 @brief Returns the name of this port
 */
- (NSString *)name;
/*!
 @brief Returns the version of this port
 */
- (NSString *)version;

/*!
 @brief Returns an array of NSString port names of dependencies of this port
 @discussion The MPPort object has internal dictionary lists of MPPort names for
 the following dependency types: depend_libs, depend_run and depend_build. The
 NSArray returned contains all of these dependencies in a single Array.
 
 ISN'T INFORMATION LOST BY JUST CREATING A SINGLE ARAY WITH ALL OF THESE DEPENDENCIES?
 PERHAPS A DIFFERENT DATA STRUCTURE CAN BE USED THAT LETS US REMEMBER WHAT TYPE OF
 DEPENDENCY EACH DEPENDENCY IS?
 */
- (NSArray *)depends;




#pragma mark --exec: and its convenience methods--
/*!
 @brief Executes the specified target for this MPPort
 @param target NSString target to be executed for this MPPort
 @discussion See *add link here to MPMacPorts documentation*
 */
- (void)exec:(NSString *)target;

/*Convenience methods based on the exec: withTarget: method
 These methods and -exec: need to be rewritten to handle variants
 and options. 
 Also, there is currently a bug with packaging targets (See
 http://trac.macports.org/ticket/10881 for more information).
 Should we run exec:@"destroot" before any of the packaging commands?"
 */

/*!
 @brief Runs a configure process for this port.
 */
-(void)configure;
/*!
 @brief Builds this port.
 */
-(void)build;
/*!
 @brief Tests this port.
 */
-(void)test;
/*!
 @brief Installs this port to a temporary directory
 */
-(void)destroot;
/*!
 @brief Installs this port.
 */
-(void)install;
/*!
 @brief Archives port for later unarchving. 
 @discussion Archive mode must be enabled for this command to work.
 This is done by setting portarchivemode to yes in the macports.conf file
 located in ${prefix}/etc/macports/macports.conf. With archive mode enabled,
 binary archives are created automatically whenever an install is performed.
 */
-(void)archive;
/*!
 @brief Creates an internet-enabled disk image containing OS X package of this
 port
 */
-(void)createDmg;
/*!
 @brief Create an internet-enabled disk image containing an OS X metapackage of this
 port
 */
-(void)createMdmg;
/*!
 @brief Creates an OS X installer package of this port
 */
-(void)createPkg;
/*!
 @brief Creates an OS X installer metapackage of this this port and 
 its dependencies
 */
-(void)createMpkg;
/*!
 @brief Creates and RPM binary package of this port. This is similar to a
 tgz "archive".
 */
-(void)createRpm;
/*!
 @brief Creates a DEB binary package of this port.
 */
-(void)createDpkg;
/*!
 @brief Creates an SRPM source package of this port, similar to a xar "portpkg".
 */
-(void)createSrpm;

/*!
 @brief Sets the attributes of this MPPort using the given string
 @param string An NSString object derived from a Tcl list containing this port's attributes
 @discussion The Tcl list is obtained from the PortIndex which contains a list of serialized
 Tcl key-value lists, one list per line. This list is then broken up into a dictionary of attributes
 for the MPPort.
 */
- (void) setPortWithTclListAsString:(NSString *)string;

/*!
 @brief Adds the name of an MPPort to the list of this MPPort's dependencies
 @param dependency The NSString name of the MPPort to be added
 @discussion This MPPort object contains an internal list of port names for MPPorts which
 it depends on. This list is returned by the depends method and is populated by this method.
 */
- (void) addDependencyAsPortName:(NSString *)dependency;

/*!
 @brief Sets the state of this MPPort object
 @discussion Possible values are MPPortStateUnknown, MPPortStateLearnState, MPPortStateActive, MPPortStateInstalled,
 MPPortStateOutdated, MPPortStateNotInstalled.
*/
- (void)setState:(int)state;
/*!
 @brief Sets the state of this MPPort object from its receipts
 @param receipts An NSArray of receipts for this port
 @discussion It is possible for an installed port to have more than one 
 receipt if the MacPorts system uses hardlinks to activate the port.
 */
 - (void)setStateFromReceipts:(NSArray *)receipts;


- (void)setDictionary:(NSDictionary *)otherDictionary;
+ (Class)classForKeyedUnarchiver;
- (Class)classForKeyedArchiver;

@end
