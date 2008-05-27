//
//  MPMutableDictionary.m
//  MacPorts.Framework
//
//  Created by Randall Hansen Wood on 26/9/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MPMutableDictionary.h"


@implementation MPMutableDictionary

- (id)init {
	self = [super init];
	if (self != nil) {
		embeddedDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithCapacity:(unsigned)numItems {
	self = [super init];
	if (self != nil) {
		embeddedDictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
	}
	return self;
}

- (void) dealloc {
	[embeddedDictionary release];
	[super dealloc];
}

- (unsigned)count {
	return [embeddedDictionary count];
}

- (NSEnumerator *)keyEnumerator {
	return [embeddedDictionary keyEnumerator];
}

- (id)objectForKey:(id)aKey {
	if ([aKey isEqualToString:@"compositeVersion"]) {
		return [[[embeddedDictionary objectForKey:@"version"] stringByAppendingString:@"_"] stringByAppendingString:[embeddedDictionary objectForKey:@"revision"]];
	}
	return [embeddedDictionary objectForKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
	[embeddedDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
	[self willChangeValueForKey:aKey];
	[embeddedDictionary setObject:anObject forKey:aKey];
	[self didChangeValueForKey:aKey];
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
	[embeddedDictionary setDictionary:otherDictionary];
}

- (NSString *)description {
	return [embeddedDictionary description];
}

- (Class)classForKeyedArchiver {
	return [MPMutableDictionary class];
}

+ (Class)classForKeyedUnarchiver {
	return [MPMutableDictionary class];
}

@end
