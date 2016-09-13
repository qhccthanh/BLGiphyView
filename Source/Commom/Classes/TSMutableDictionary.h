//
//  TSMutableDictionary.h
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSMutableDictionary : NSMutableDictionary

/**
 *  Add an Object associated with aKey to cache
 *
 *  @param anObject An Object for aKey
 *               Raises an NSInvalidArgumentException if anObject is nil. If you need to represent a nil value in the dictionary, use NSNull.
 *  @param aKey  The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol). If aKey already exists in the cache, image takes its place.
 */
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

/**
 *  Returns the object associated with a given key.
 *  The object associated with aKey, or nil if no object is associated with aKey.
 *
 *  @param aKey The key for which to return the corresponding object.
 *
 *  @return The object in dictionary which associated with aKey
 */
- (id)objectForKey:(id)aKey;

/**
 *  Remove an object from dictionary associated with aKey
 *  Does nothing if aKey does not exist
 *
 *  @param aKey The key to remove
 */
- (void)removeObjectForKey:(id)aKey;

/**
 *  Remove all objects in dictionary.
 */
- (void)removeAllObjects;

/**
 *  Get number of objects in dictionary.
 */
- (NSUInteger)count;

/**
 *  Get All Keys
 *
 *  @return The all keys 
 */
- (NSArray *)allKeys;

@end
