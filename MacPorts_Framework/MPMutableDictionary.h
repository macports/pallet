//
//  MPMutableDictionary.h
//  MacPorts.Framework
//
//  Created by Randall Hansen Wood on 26/9/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

/*!
 @header
 MPMutableDictionary is a customized NSMutableDictionary object that
 serves as the base of most MacPort Framework objects.
 */

#import <Cocoa/Cocoa.h>

/*!
 @class MPMutableDictionary
 @abstract A subclass of NSMutableDictionary that is the base of most MacPort API objects
 @discussion The dictionary data structure is appropriate for representing various aspects
 of the MacPorts system such as port objects, receipt objects etc. Clients of this framework
 can treat subclasses of MPMutableDictionary objects as NSMutableDictionaries which can
 be useful for some GUI programming tasks like displaying information in a table. In order
 to properly subclass an NSMutableDictionary, this class also contains an internal NSMutableDictionary
 object. See http://www.smackie.org/Notes/2007/07/11/subclassing-nsmutabledictionary/ for some more
 information on subclassing NSMutableDictionary.
 */

@interface MPMutableDictionary : NSMutableDictionary {
	
	NSMutableDictionary *embeddedDictionary;
	
}

/*!
 @brief Calls [initWithCapacity:15]
 */
- (id)init;
/*!
 @brief Initializes this object with a specified number of key, value pairs.
 @param numItems The initial size of this MPMutableDictionary object.
 */
- (id)initWithCapacity:(unsigned)numItems;

/*!
 @brief Returns the size of this mutable dictionary
 */
- (unsigned)count;

/*!
 @brief Returns an NSEnumerator object for accessing keys in the mutable dictionary
 */
- (NSEnumerator *)keyEnumerator;

/*!
 @brief Returns the object associated with a given key
 @param aKey The key for which to return the corresponding object
 */
- (id)objectForKey:(id)aKey;

/*!
 @brief Removes a given key and its associated object from the mutable dictionary
 @param aKey The key to be removed
 */
- (void)removeObjectForKey:(id)aKey;
/*!
 @brief Adds a given key and its associated object to the mutable dictionary.
 @param anObject The value for the key to be added.
 @param aKey The key for the value to be added.
 @discussion This class uses an embedded NSMutableDictionary for implementing these
 primitive methods. Hence restrictions to setObject: forKey: for NSMutableDictionary
 apply here also; for example, anObject cannot be nil.
 */
- (void)setObject:(id)anObject forKey:(id)aKey;

/*!
 @brief Sets the contents of the mutable dictionary to entries in a given dictionary
 @param otherDictionary A dictionary containing the new entries
 */
- (void)setDictionary:(NSDictionary *)otherDictionary;

/*!
@brief Returns an NSString representation of the contents of this mubtable dictioanry, formatted as a property list.
 */
- (NSString *)description;

/*
 @brief Returns an MPMutableDictionary class object for keyed unarchiving
 @discussion This method has to be overriden to prevent the decoding of instances
 of this class as NSMutableDictionary objects during unarchiving. See hyperlink
 in class description notes for more information on this.
 */
+ (Class)classForKeyedUnarchiver;
/*
 @brief Returns an MPMutableDictioanry class object for keyed archiving
 @discussion Implementing this method ensures that instances of this class are
 archived as MPMutableDictionary objects rather than NSMutableDictionary objects.
 See link in class description notes for more details.
 */
 - (Class)classForKeyedArchiver;

@end
