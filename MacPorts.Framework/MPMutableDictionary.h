//
//  MPMutableDictionary.h
//  MacPorts.Framework
//
//  Created by Randall Hansen Wood on 26/9/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MPMutableDictionary : NSMutableDictionary {
	
	NSMutableDictionary *embeddedDictionary;
	
}

- (id)init;
- (id)initWithCapacity:(unsigned)numItems;

- (unsigned)count;
- (NSEnumerator *)keyEnumerator;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)setDictionary:(NSDictionary *)otherDictionary;
- (NSString *)description;

+ (Class)classForKeyedUnarchiver;
- (Class)classForKeyedArchiver;

@end
