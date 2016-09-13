//
//  YLImageCache.m
//  YALO
//
//  Created by BaoNQ on 8/1/16.
//  Copyright © 2016 admin. All rights reserved.
//


#import "YLImageCache.h"

#define kYLImageCacheSize 30 * 1024 * 1024
#define kYLImageCacheLength 26
#define kNumberDeleteCacheItem 1

@interface YLImageCache ()

@property NSMutableDictionary *cachedImage;
@property dispatch_queue_t internalSerialQueue;
@property NSMutableArray *priorityQueue;
@property NSInteger currentSize;

@end

@implementation YLImageCache

//Singleton Method
+ (id)sharedCachedImage {
    
    static YLImageCache *sharedCachedImage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCachedImage = [[self alloc] init];
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            
//        }];
    });
    
    return sharedCachedImage;
}

- (id)init {
    
    self = [super init];
    if (!self)
        return nil;
    
    _cachedImage = [[NSMutableDictionary alloc] init];
    _internalSerialQueue = dispatch_queue_create("com.vng.YLImageCacheQueue", DISPATCH_QUEUE_SERIAL);
    
    _cacheLength = kYLImageCacheLength;
    _cacheSize = kYLImageCacheSize;
    _currentSize = 0;
    _cacheMode = kYLCacheModeLimitLengthAndSize;

    _priorityQueue = [[NSMutableArray alloc]init];
    
    return self;
}

- (BOOL)updateCacheLength:(NSInteger)length {
    
    if (length > [_priorityQueue count]) {
        _cacheLength = length;
        return YES;
    } else
        return NO;
}

- (BOOL)updateCacheSize:(NSInteger)size {
    
    if (size > _currentSize) {
        _currentSize = size;
        return YES;
    }
    else
        return NO;
}

- (void)setCacheMode:(YLCacheMode)cacheMode {
    
    _cacheMode = cacheMode;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey {
    
    if (image == nil || aKey == nil)
        return;
    
    
    NSInteger sizeOfImage = CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage);
    __block BOOL isFullCache = NO;
    if (
        ( (_cacheMode | kYLCacheModeLimitLength) && [_cachedImage count] >= _cacheLength) ||
        ((_cacheMode | kYLCacheModeLimitSize) && (_currentSize + sizeOfImage) > _cacheSize)) {
        
        isFullCache = YES;
    }
    dispatch_async(_internalSerialQueue, ^{
        if (!isFullCache){
            // Image cache is not full. Add this image to cache and push it to priority queue.
            
            [_cachedImage setObject:image forKey:aKey];
            [_priorityQueue addObject:aKey];
            
        } else {
            // Image cache is full.
            // Delete least recently used image until cache is available for this image.
            while (isFullCache) {
                
                _currentSize -= sizeOfImage;
                
                // Remove number cache item
                while (_priorityQueue.count >= kYLImageCacheLength) {
                    id firstObject = [_priorityQueue firstObject];
                    if (firstObject) {
                        [_cachedImage removeObjectForKey:firstObject];
                        [_priorityQueue removeObjectAtIndex:0];
                    }
                }
                
                if (((_cacheMode | kYLCacheModeLimitLength) && [_cachedImage count] < _cacheLength) ||
                    ((_cacheMode | kYLCacheModeLimitSize) && (_currentSize + sizeOfImage) <= _cacheSize)) {
                    
                    isFullCache = NO;
                }
            }
            // Add this image to cache and push it to priority queue.
            [_cachedImage setObject:image forKey:aKey];
            [_priorityQueue addObject:aKey];
        }
        _currentSize += sizeOfImage;
    });
}

- (UIImage *)imageForKey:(NSString *)aKey {
    
    __block UIImage *returnedImage;
    
    dispatch_sync(_internalSerialQueue, ^{
        returnedImage = [_cachedImage objectForKey:aKey];
        
        if (returnedImage){
            NSInteger index = -1;
            for (NSInteger i = 0; i < [_priorityQueue count]; i++){
                if ([aKey isEqualToString:[_priorityQueue objectAtIndex:i]])
                {
                    index = i;
                    break;
                }
            }
            if (index != -1) {
                [_priorityQueue removeObjectAtIndex:index];
                [_priorityQueue addObject:aKey];
            }
        }
    });
    
    return returnedImage;
}

- (void)removeImageForKey:(NSString *)aKey {
    
    dispatch_async(_internalSerialQueue, ^{
        UIImage *image = [_cachedImage objectForKey:aKey];
        
        _currentSize -= CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage);
        [_cachedImage removeObjectForKey:aKey];
        
        NSInteger index = -1;
        for (NSInteger i = 0; i < [_priorityQueue count]; i++){
            if ([aKey isEqualToString:[_priorityQueue objectAtIndex:i]])
            {
                index = i;
                break;
            }
        }
        if (index != -1)
            [_priorityQueue removeObjectAtIndex:index];
    });
}

- (void)removeAllObjects{
    
    dispatch_async(_internalSerialQueue, ^{
        [_cachedImage removeAllObjects];
        [_priorityQueue removeAllObjects];
        _currentSize = 0;
    });
}

@end

