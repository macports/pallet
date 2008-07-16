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

- (id)init {
	self = [super initWithCapacity:15];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
	}
	return self;
}

- (id)initWithCapacity:(unsigned)numItems {
	self = [super initWithCapacity:numItems];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
	}
	return self;
}

- (id) initWithTclListAsString:(NSString *)string {
	self = [super initWithCapacity:15];
	if (self != nil) {
		[self setState:MPPortStateUnknown];
		[self setPortWithTclListAsString:string];
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
		if ([[self valueForKey:@"long_description"] characterAtIndex:0] == '{') {
			[self setValue:[self valueForKey:@"description"] forKey:@"long_description"];
		}
	} 
	@catch (NSException *e) {
		[self setValue:[NSString stringWithFormat:
			NSLocalizedStringWithDefaultValue(@"setPortWithTclListAsStringDescreiptionError",
											  @"Localizable",
											  [NSBundle mainBundle],
											  @"Port has an invalid desciption or long_description key.",
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


/*
 TO DO : Delete this method when scrubbing code
 
- (void)exec:(NSString *)target {
	MPInterpreter *interpreter;
	interpreter = [MPInterpreter sharedInterpreter];
	[interpreter evaluateArrayAsString:[NSArray arrayWithObjects:
		@"set portHandle [mportopen ",
		[self valueForKey:@"portURL"],
		@"]; mportexec portHandle",
		target,
		@";",
		@"mportclose portHandle",
		nil]];
}
*/



//This method is nice but really isn't used.
- (void)execPortProc:(NSString *)procedure withParams:(NSArray *)params {
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
	
	[interpreter evaluateStringAsString:
	 [NSString stringWithFormat:@"[%@ %@]" , procedure, sparams]];
}


//Used for mportactivate, mportdeactivate and mportuninstall
-(void)execPortProc:(NSString *)procedure withOptions:(NSArray *)options withVersion:(NSString *)version {
	NSString *opts, *v;
	MPInterpreter *interpreter;
	opts = [NSString stringWithString:@" "];
	v = [NSString stringWithString:[self name]];
	interpreter = [MPInterpreter sharedInterpreter];
	
	if (version != NULL)
		v = [NSString stringWithString:version];
	else 
		v = [NSString stringWithString:[self version]];
	
	if (options != NULL) 
		opts = [NSString stringWithString:[options componentsJoinedByString:@" "]];	
	
	[interpreter evaluateStringAsString:
	 [NSString stringWithFormat:
	  @"[%@ %@ %@ %@]" ,
	  procedure, [self name], v, opts]];
}

//Used for the rest of other exec procedures
-(void)exec:(NSString *)target withOptions:(NSArray *)options withVariants:(NSArray *)variants {
	NSString *opts; 
	NSString *vrnts;
	MPInterpreter *interpreter;
	opts = [NSString stringWithString:@" "];
	vrnts = [NSString stringWithString:@" "];
	interpreter = [MPInterpreter sharedInterpreter];
	
	if (options != NULL) {
		opts = [NSString stringWithString:[options componentsJoinedByString:@" "]];
	}
	if (variants != NULL) {
		vrnts = [NSString stringWithString:[variants componentsJoinedByString:@" "]];
	}
	
	[interpreter evaluateStringAsString:
	 [NSString stringWithFormat:
	  @"set portHandle [mportopen  %@  %@  %@]; \
	  mportexec portHandle %@; \
	  mportclose portHandle", 
	  [self valueForKey:@"portURL"], opts, vrnts, target]];
	
}

-(void)sendGlobalExecNotification:(NSString *)target withStatus:(NSString *)status {
	NSString * notificationName = [NSString stringWithString:@"MacPorts"];
	notificationName = [notificationName stringByAppendingString:target];
	notificationName = [notificationName stringByAppendingString:status];
	
	//Should I be sending self as the object? Or should I send a newly created
	//copy? What if the listener modifies this object? 
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName 
																   object:self]; 
}



#pragma mark -
# pragma mark Exec methods 
- (void)uninstallWithOptions:(NSArray *)options withVersion:(NSString *)version {
	
	[self sendGlobalExecNotification:@"Uninstall" withStatus:@"Started"];
	[self execPortProc:@"mportuninstall" withOptions:options withVersion:version];
	[self sendGlobalExecNotification:@"Uninstall" withStatus:@"Finished"];
}

- (void)activateWithOptions:(NSArray *)options withVersion:(NSString *)version {
	[self sendGlobalExecNotification:@"Activate" withStatus:@"Started"];
	[self execPortProc:@"mportactivate" withOptions:options withVersion:version];
	[self sendGlobalExecNotification:@"Activate" withStatus:@"Finished"];
}

- (void)deactivateWithOptions:(NSArray *)options withVersion:(NSString *)version {
	[self sendGlobalExecNotification:@"Deactivate" withStatus:@"Started"];
	[self execPortProc:@"mportdeactivate" withOptions:options withVersion:version];
	[self sendGlobalExecNotification:@"Deactivate" withStatus:@"Finished"];
}

-(void)configureWithOptions:(NSArray *)options withVariants:(NSArray *)variants{
	[self sendGlobalExecNotification:@"Configure" withStatus:@"Started"];
	[self exec:@"configure" withOptions:options withVariants:variants];
}
-(void)buildWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Build" withStatus:@"Started"];
	[self exec:@"build" withOptions:options withVariants:variants];
}
-(void)testWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Test" withStatus:@"Started"];
	[self exec:@"test" withOptions:options withVariants:variants];	
}
-(void)destrootWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Destroot" withStatus:@"Started"];
	[self exec:@"destroot" withOptions:options withVariants:variants];
}
-(void)installWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Install" withStatus:@"Started"];
	[self exec:@"install" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Install" withStatus:@"Finished"];
}
-(void)archiveWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Archive" withStatus:@"Started"];
	[self exec:@"archive" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Archive" withStatus:@"Finished"];
}
-(void)createDmgWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Dmg" withStatus:@"Started"];
	[self exec:@"dmg" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Dmg" withStatus:@"Finished"];
}
-(void)createMdmgWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Mdmg" withStatus:@"Started"];
	[self exec:@"mdmg" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Mdmg" withStatus:@"Finished"];
}
-(void)createPkgWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Pkg" withStatus:@"Started"];
	[self exec:@"pkg" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Pkg" withStatus:@"Finished"];
}
-(void)createMpkgWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Mpkg" withStatus:@"Started"];
	[self exec:@"mpkg" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Mpkg" withStatus:@"Finished"];
}
-(void)createRpmWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Rpm" withStatus:@"Started"];
	[self exec:@"rpm" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Rpm" withStatus:@"Finished"];
}
-(void)createDpkgWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Dpkg" withStatus:@"Started"];
	[self exec:@"dpkg" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Dpkg" withStatus:@"Finished"];
}
-(void)createSrpmWithOptions:(NSArray *)options withVariants:(NSArray *)variants {
	[self sendGlobalExecNotification:@"Srpm" withStatus:@"Started"];
	[self exec:@"srpm" withOptions:options withVariants:variants];
	[self sendGlobalExecNotification:@"Srpm" withStatus:@"Finished"];
}

# pragma mark -


#pragma mark MPMutableDictionary Protocal

- (id)objectForKey:(id)aKey {
	if ([aKey isEqualToString:@"receipts"] && ![super objectForKey:aKey]) {
		[self setObject:[[[MPRegistry sharedRegistry] installed:[self objectForKey:@"name"]] objectForKey:[self objectForKey:@"name"]]forKey:aKey];
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
