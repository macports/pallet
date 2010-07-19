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

#import "MPPort.h"


@implementation MPPort

// Each of the init methods sets the parent MPMacPorts object for this MPPort object
// if it hasn't already been set. We are assuming that this MPPort object and its
// parent MPMacPort object would have been created in the same thread. That might
// not have been the case. I should make a note of that in the release notes and 
// also add some more sane changes later for a closer coupling of an MPMacPorts 
// object and its associated MPPort objects.

- (id)init {
	self = [super initWithCapacity:15];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
		if (parentMacPortsInstance != nil)
			parentMacPortsInstance = [MPMacPorts sharedInstance];
		
	}
	return self;
}

- (id)initWithCapacity:(unsigned)numItems {
	self = [super initWithCapacity:numItems];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
		if (parentMacPortsInstance != nil)
			parentMacPortsInstance = [MPMacPorts sharedInstance];
	}
	return self;
}

- (id) initWithTclListAsString:(NSString *)string {
	self = [super initWithCapacity:15];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
		[self setPortWithTclListAsString:string];
		if (parentMacPortsInstance != nil)
			parentMacPortsInstance = [MPMacPorts sharedInstance];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) setPortWithTclListAsString:(NSString *)string {
	MPInterpreter *interpreter;
	interpreter = [MPInterpreter sharedInterpreter];
	[self setDictionary:[interpreter dictionaryFromTclListAsString:string]];
	// for each of the following properties:
	// create strings for tokenizable properties to facilitate rapid searching
	// tokenize the properties
	// create sets of the depends_* tokenized properties that contain only the dependency name, not the dependency type
	// make the descriptions readable
	if ([self objectForKey:@"maintainers"] != nil) {
		[self setObject:[self objectForKey:@"maintainers"] forKey:@"maintainersAsString"];		
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"maintainers"]] forKey:@"maintainers"];
	}
	if ([self objectForKey:@"categories"] != nil) {
		[self setObject:[self objectForKey:@"categories"] forKey:@"categoriesAsString"];
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"categories"]] forKey:@"categories"];
	}
	if ([self objectForKey:@"variants"] != nil) {
		[self setObject:[self objectForKey:@"variants"] forKey:@"variantsAsString"];
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"variants"]] forKey:@"variants"];
	}
	if ([self objectForKey:@"depends_build"] != nil) {
		[self setObject:[self objectForKey:@"depends_build"] forKey:@"depends_buildAsString"];
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"depends_build"]] forKey:@"depends_build"];
		[self addDependencyAsPortName:@"depends_build"];
	}
	if ([self objectForKey:@"depends_lib"] != nil) {
		[self setObject:[self objectForKey:@"depends_lib"] forKey:@"depends_libAsString"];
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"depends_lib"]] forKey:@"depends_lib"];
		[self addDependencyAsPortName:@"depends_lid"];
	}
	if ([self objectForKey:@"depends_run"] != nil) {
		[self setObject:[self objectForKey:@"depends_run"] forKey:@"depends_runAsString"];
		[self setObject:[interpreter arrayFromTclListAsString:[self objectForKey:@"depends_run"]] forKey:@"depends_run"];
		[self addDependencyAsPortName:@"depends_run"];
	}
	
	@try {
		if ([[self valueForKey:@"description"] characterAtIndex:0] == '{') {
			[self setValue:[self valueForKey:@"description"] forKey:@"description"];
		}
	} 
	@catch (NSException *e) {
		[self setValue:[NSString stringWithFormat:
						NSLocalizedStringWithDefaultValue(@"setPortWithTclListAsStringDescreiptionError",
														  @"Localizable",
														  [NSBundle mainBundle],
														  @"Port has an invalid desciption key.",
														  @"Error statement for exception raised when testing description.")]
				forKey:@"description"];
	}
	
	@try {
		if ([[self valueForKey:@"long_description"] characterAtIndex:0] == '{') {
			[self setValue:[self valueForKey:@"long_description"] forKey:@"long_description"];
		}
	} 
	@catch (NSException *e) {
		[self setValue:[NSString stringWithFormat:
						NSLocalizedStringWithDefaultValue(@"setPortWithTclListAsStringDescreiptionError",
														  @"Localizable",
														  [NSBundle mainBundle],
														  @"Port has an invalid long_description key.",
														  @"Error statement for exception raised when testing long_description.")]
				forKey:@"long_description"];
	}
	// set the status flag to unknown
	[self setState:MPPortStateUnknown];
}	

- (void)addDependencyAsPortName:(NSString *)dependency {
	NSMutableArray *array;
	int i;
	array = [[NSMutableArray alloc] initWithArray:[self objectForKey:dependency]];
	for (i = 0; i < [array count]; i++) {
		[array replaceObjectAtIndex:i withObject:[[[array objectAtIndex:i] componentsSeparatedByString:@":"] lastObject]];
	}
	[self setObject:[[NSArray alloc] initWithArray:array] forKey:[dependency stringByAppendingString:@"AsPortName"]];	
}

- (NSString *)name {
	return [self objectForKey:@"name"];
}

- (NSString *)version {
	return [self objectForKey:@"version"];
}

- (NSArray *)depends {
	return [[[NSArray arrayWithArray:[self valueForKey:@"depends_build"]]
			 arrayByAddingObjectsFromArray:[self valueForKey:@"depends_lib"]] 
			arrayByAddingObjectsFromArray:[self valueForKey:@"depends_run"]];
}


-(void)sendGlobalExecNotification:(NSString *)target withStatus:(NSString *)status {
	NSString * notificationName = [NSString stringWithString:@"MacPorts"];
	notificationName = [notificationName stringByAppendingString:target];
	notificationName = [notificationName stringByAppendingString:status];
	
	//Should I be sending self as the object? Or should I send a newly created
	//copy? What if the listener modifies this object? 
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName 
																   object:nil]; 
}



//Used for mportactivate, mportdeactivate and mportuninstall
-(void)execPortProc:(NSString *)procedure 
		withOptions:(NSArray *)options 
			version:(NSString *)version
			  error:(NSError **)execError {
	
	NSString *opts, *v;
	MPInterpreter *interpreter;
	opts = [NSString stringWithString:@" "];
	//v = [NSString stringWithString:[self name]];
	interpreter = [MPInterpreter sharedInterpreter];
	
	if (version != NULL)
		v = [NSString stringWithString:version];
	else 
		v = @"";
		//v = [NSString stringWithString:[self version]];
	
	if (options != NULL) 
		opts = [NSString stringWithString:[options componentsJoinedByString:@" "]];	
	
	//Send Global Notifications and update MPNotifications variable
	[self sendGlobalExecNotification:procedure withStatus:@"Started"];
	//NSString * tclCmd = [@"YES_" stringByAppendingString:procedure];
	[[MPNotifications sharedListener] setPerformingTclCommand:procedure];
	
	if ([parentMacPortsInstance authorizationMode]) {
		[interpreter evaluateStringWithMPHelperTool: 
		 [NSString stringWithFormat:
		  @"%@ %@ %@ %@" ,
		  procedure, [self name], v, opts]
											  error:execError];
		
	}
	else {
		[interpreter evaluateStringWithPossiblePrivileges:
		 [NSString stringWithFormat:
		  @"%@ %@ %@ %@" ,
		  procedure, [self name], v, opts]
													error:execError];		
	}
    // I must get the new state of the port from the registry
	// instead of just [self setState:MPPortStateLearnState];
    //NSArray *receipts  = [[[MPRegistry sharedRegistry] installed:[self name]] objectForKey:[self name]];
    //[self setStateFromReceipts:receipts];
    [self removeObjectForKey:@"receipts"];
    [self setState:MPPortStateLearnState];
    
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[self sendGlobalExecNotification:procedure withStatus:@"Finished"];
}

//Used for the rest of other exec procedures
-(void) exec:(NSString *)target 
	 withOptions:(NSArray *)options 
	variants:(NSArray *)variants 
	   error:(NSError **)execError{
	
	NSMutableString *opts; 
	NSMutableString *vrnts;
	MPInterpreter *interpreter;
	opts = [NSMutableString stringWithCapacity:50];
	[opts setString:@"{ "];
	vrnts = [NSMutableString stringWithCapacity:50];
	[vrnts setString:@"{ "];
	interpreter = [MPInterpreter sharedInterpreter];
	
	
	if (options != NULL) {
		[opts appendString: [NSString stringWithString:[options componentsJoinedByString:@" "]]];
	}
	
	[opts appendString: @" }"];

	if (variants != NULL) {
		[vrnts appendString: [NSString stringWithString:[variants componentsJoinedByString:@" "]]];
	}
	
	[vrnts appendString: @" }"];
	
	//NSLog(@"Variants String: %@", vrnts);
	//Send Global Notifications and update MPNotifications variable
	[self sendGlobalExecNotification:target withStatus:@"Started"];
	//NSString * tclCmd = [@"YES_" stringByAppendingString:target];
	[[MPNotifications sharedListener] setPerformingTclCommand:target];
	
	/*
	NSLog(@"Interpreter string:\n%@",[NSString stringWithFormat:
									  @"set portHandle [mportopen  %@  %@  %@]; mportexec  $portHandle %@; mportclose $portHandle", 
									  [self valueForKey:@"porturl"], opts, vrnts, target]);
	*/
    [interpreter evaluateStringWithPossiblePrivileges:
        [NSString stringWithFormat:
            @"set portHandle [mportopen  %@  %@  %@]; mportexec  $portHandle %@; mportclose $portHandle", 
            [self valueForKey:@"porturl"], opts, vrnts, target]
        error:execError];
	
	
	[self setState:MPPortStateLearnState];
	[[MPNotifications sharedListener] setPerformingTclCommand:@""];
	[self sendGlobalExecNotification:target withStatus:@"Finished"];
	
}


//This method is nice but really isn't used.
- (void)execPortProc:(NSString *)procedure withParams:(NSArray *)params error:(NSError **)execError {
	
	//params can contain either NSStrings or NSArrays
	NSString * sparams = [NSString stringWithString:@" "];
	NSEnumerator * penums = [params objectEnumerator];
	MPInterpreter *interpreter = [MPInterpreter sharedInterpreter];
	
	id elem;
	
	while (elem = [penums nextObject]) {
		if ([elem isMemberOfClass:[NSString class]]) {
			sparams = [sparams stringByAppendingString:elem];
			sparams = [sparams stringByAppendingString:@" "];
		}
		
		else if ([elem isKindOfClass:[NSArray class]]) {
			//Maybe I should be more careful in the above if statement and
			//explicitly check for the classes i'm interested in?
			sparams = [sparams stringByAppendingString:[elem componentsJoinedByString:@" "]];
			sparams = [sparams stringByAppendingString:@" "];
		}
	}
	
	if( [parentMacPortsInstance authorizationMode] ) {
		[interpreter evaluateStringWithMPHelperTool:[NSString stringWithFormat:@"[%@ %@]" , procedure, sparams] 
									  error:execError];
	}
	else {
		[interpreter evaluateStringAsString:[NSString stringWithFormat:@"[%@ %@]" , procedure, sparams] 
									  error:execError];
	}
	
	
}


#pragma mark -
# pragma mark Exec methods 
- (void)uninstallWithVersion:(NSString *)version error:(NSError **)mError {
	if (version == nil) {
		[self execPortProc:@"mportuninstall" withOptions:nil version:@"" error:mError];
	}
	else {
		[self execPortProc:@"mportuninstall" withOptions:nil version:version error:mError];
	}
}

- (void)activateWithVersion:(NSString *)version error:(NSError **)mError {
	if (version == nil) {
		[self execPortProc:@"mportactivate" withOptions:nil version:@"" error:mError];
	}
	else {
		[self execPortProc:@"mportactivate" withOptions:nil version:version error:mError];
	}
		
}

- (void)deactivateWithVersion:(NSString *)version error:(NSError **)mError {
	if (version == nil) {
		[self execPortProc:@"mportdeactivate" withOptions:nil version:@"" error:mError];
	}
	else {
		[self execPortProc:@"mportdeactivate" withOptions:nil version:version error:mError];
	}
}

- (void)upgradeWithError:(NSError **)mError {
	[self execPortProc:@"mportupgrade" withOptions:nil version:@"" error:mError];
}

-(void)configureWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"configure" withOptions:options variants:variants error:mError];
}

-(void)buildWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"build" withOptions:options variants:variants error:mError];
}

-(void)testWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"test" withOptions:options variants:variants error:mError];	
}

-(void)destrootWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"destroot" withOptions:options variants:variants error:mError];
}

-(void)installWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"install" withOptions:options variants:variants error:mError];
}

-(void)archiveWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"archive" withOptions:options variants:variants error:mError];
}

-(void)createDmgWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"dmg" withOptions:options variants:variants error:mError];
}

-(void)createMdmgWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"mdmg" withOptions:options variants:variants error:mError];
}

-(void)createPkgWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"pkg" withOptions:options variants:variants error:mError];
}

-(void)createMpkgWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError {
	[self exec:@"mpkg" withOptions:options variants:variants error:mError];
}

-(void)createRpmWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError{
	[self exec:@"rpm" withOptions:options variants:variants error:mError];
}

-(void)createDpkgWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError{
	[self exec:@"dpkg" withOptions:options variants:variants error:mError];
}

-(void)createSrpmWithOptions:(NSArray *)options variants:(NSArray *)variants error:(NSError **)mError{
	[self exec:@"srpm" withOptions:options variants:variants error:mError];
}


# pragma mark -


#pragma mark MPMutableDictionary Protocol

- (id)objectForKey:(id)aKey {
	if ([aKey isEqualToString:@"receipts"] && ![super objectForKey:aKey]) {
        NSArray *receipts = [[[MPRegistry sharedRegistry] installed:[self objectForKey:@"name"]] objectForKey:[self objectForKey:@"name"]];
        if (receipts == nil) {
            return nil;
        } else {
            [self setObject:receipts forKey:aKey];
        }
	}
	return [super objectForKey:aKey];
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
	[super setDictionary:otherDictionary];
	[self setState:MPPortStateUnknown];
}

- (void)setState:(int)state {
	id receipt;
	NSEnumerator *receiptsEnumerator;
	switch (state) {
		case MPPortStateLearnState:
			if ([self objectForKey:@"receipts"]) {
				receiptsEnumerator = [[self objectForKey:@"receipts"] objectEnumerator];
				// the following logic is flawed - it makes the assuption that if the active version is not equal to the
				// version in the PortIndex that the port is outdated + I don't know that this logic works at all on 
				// direct installs
				[self setState:MPPortStateInstalled];
				while (receipt = [receiptsEnumerator nextObject]) {
					if ([receipt valueForKey:@"active"]) {
						[self setState:MPPortStateActive];
						[self setObject:receipt forKey:@"active"];
						if (![[receipt valueForKey:@"compositeVersion"] isEqualToString:[self valueForKey:@"compositeVersion"]]) {
							[self setState:MPPortStateOutdated];
						}
					}
				}
			} else {
				[self setState:MPPortStateNotInstalled];
			}
			break;
		case MPPortStateUnknown:
			[self removeObjectForKey:@"active"];
			[self removeObjectForKey:@"receipts"];
			[super setObject:[NSNumber numberWithInt:MPPortStateUnknown] forKey:@"state"];
			break;
		default:
			[super setObject:[NSNumber numberWithInt:state] forKey:@"state"];
			break;
	}
}

- (void)setStateFromReceipts:(NSArray *)receipts {
    [self setObject:receipts forKey:@"receipts"];
	[self setState:MPPortStateLearnState];
}

- (Class)classForKeyedArchiver {
	return [MPPort class];
}

+ (Class)classForKeyedUnarchiver {
	return [MPPort class];
}

@end
