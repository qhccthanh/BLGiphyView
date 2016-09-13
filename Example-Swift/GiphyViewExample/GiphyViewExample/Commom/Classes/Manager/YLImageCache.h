//
//  YLImageCache.h
//  YALO
//
//  Created by BaoNQ on 8/1/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YLCacheMode) {
    kYLCacheModeNormal = 0,
    kYLCacheModeLimitLength = 1,
    kYLCacheModeLimitSize = 1 << 1,
    kYLCacheModeLimitLengthAndSize = 3,
};

@interface YLImageCache : NSObject

@property (assign, readonly) NSInteger cacheLength;
@property (assign, readonly) NSInteger cacheSize;
@property (assign, readonly) YLCacheMode cacheMode;

/**
 *  Singletion method of image caching.
 */
+ (id)sharedCachedImage;

/**
 *  Add an image associated with aKey to cache
 *
 *  @param image An image for aKey
 *               Raises an NSInvalidArgumentException if anObject is nil. If you need to represent a nil value in the dictionary, use NSNull.
 *  @param aKey  The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol). If aKey already exists in the cache, image takes its place.
 */
- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey;

/**
 *  Set mode of cache
 *
 *  @param cacheMode The new mode of cache
 */
- (void)setCacheMode:(YLCacheMode)cacheMode;

/**
 *  Update cache with new length (maximum of image in cache)
 *
 *  @param length The unsigned integer define maximum images in cache
 */
- (BOOL)updateCacheLength:(NSInteger)length;

/**
 *  Update cache with new size (maximum of size of cache)
 *
 *  @param length The unsigned integer define maximum size of cache
 */
- (BOOL)updateCacheSize:(NSInteger)size;

/**
 *  Returns the value associated with a given key.
 *  The value associated with aKey, or nil if no value is associated with aKey.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The image in cache which associated with aKey
 */
- (UIImage *)imageForKey:(NSString *)aKey;

/**
 *  Remove an image from cache associated with aKey
 *  Does nothing if aKey does not exist
 *
 *  @param aKey The key to remove
 */
- (void)removeImageForKey:(NSString *)aKey;

/**
 *  Remove all images from cache
 */
- (void)removeAllObjects;

@end
