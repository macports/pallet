//
//  MPActionLauncher.h
//  MPGUI
//
//  Created by Juan Germán Castañeda Echevarría on 6/15/09.
//  Copyright 2009 UNAM. All rights reserved.
//

/*!
 @header MPActionLauncher
 The MPActionLauncher allows acces to a shared per thread MacPorts Framework 
 wrapper to excecute MacPorts actions. It performs all the actions in another 
 thread in order to leave the GUI responsive.
*/

#import <Cocoa/Cocoa.h>
#import <MacPorts/MacPorts.h>
#import <Growl/Growl.h>

/* Defining growl types*/

/**/
#define GROWL_TYPES 10
#define GROWL_INSTALL 0
#define GROWL_UNINSTALL 1
#define GROWL_UPGRADE 2
#define GROWL_SYNC 3
#define GROWL_SELFUPDATE 4
#define GROWL_INSTALLFAILED 5
#define GROWL_UNINSTALLFAILED 6
#define GROWL_UPGRADEFAILED 7
#define GROWL_SYNCFAILED 8
#define GROWL_SELFUPDATEFAILED 9


/*!
 @class MPActionLauncher
 @abstract Wrapper for MacPorts Framework actions
 @discussion Contains a shared per thread MacPorts Framework wrapper
*/
@interface MPActionLauncher : NSObject <GrowlApplicationBridgeDelegate> {
    NSArray *ports;
    NSTask *actionTool;
    NSConnection *connectionToActionTool;
    BOOL isLoading;
}
/*! 
 @var ports
 @abstract An array of available MPPorts
*/
@property (copy) NSArray *ports;

@property NSTask *actionTool;

/*! 
 @var isLoading
 @abstract Tells whether the instance is loading the ports array or not
*/
@property BOOL isLoading;

/*!
 @brief Return singleton shared MPActionLauncher instance
*/
+ (MPActionLauncher*)sharedInstance;

/*!
 @brief Loads the MPPorts array with the available ports current PKGPath in another thread
*/
- (void)loadPorts;

/*!
 @brief Installs a single port in another thread
 @param port MPPort that represents the port to install
*/
- (void)installPort:(MPPort *)port;

/*!
 @brief Uninstalls a single port in another thread
 @param port MPPort that represents the port to install
 */
- (void)uninstallPort:(MPPort *)port;

/*!
 @brief Upgrades a single port in another thread
 @param port MPPort that represents the port to upgrade
 */
- (void)upgradePort:(MPPort *)port;


/*!
 @brief Syncs the MacPorts installation in another thread
 */
- (void)sync;

/*!
 @brief Selfupdates the MacPorts installation in another thread
 */
- (void)selfupdate;

- (void)cancelPortProcess;

-(void) sendGrowlNotification: (int) type;

@end
