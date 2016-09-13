//
//  TSMutableDictionary.m
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "TSMutableDictionary.h"

@interface TSMutableDictionary ()

@property NSMutableDictionary *internalDictionary;
@property dispatch_queue_t internalSerialQueue;

@end

@implementation TSMutableDictionary

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    _internalDictionary = [[NSMutableDictionary alloc] init];
    _internalSerialQueue = dispatch_queue_create("com.vng.ThreadSafeMutableDictionarySerialQueue", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject == nil || aKey == nil)
        return;

    dispatch_async(_internalSerialQueue, ^{
        [_internalDictionary setObject:anObject forKey:aKey];
    });
}

- (id)objectForKey:(id)aKey {
    __block id object;
    dispatch_sync(_internalSerialQueue, ^{
        object = [_internalDictionary objectForKey:aKey];
    });
    return object;
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_async(_internalSerialQueue, ^{
        [_internalDictionary removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects {
    dispatch_async(_internalSerialQueue, ^{
        [_internalDictionary removeAllObjects];
    });
}

- (NSUInteger)count {
    __block NSUInteger numberOfObjects;
    dispatch_sync(_internalSerialQueue, ^{
        numberOfObjects = [_internalDictionary count];
    });
    return numberOfObjects;
}

- (NSArray *)allKeys {
     __block NSArray *allKeys;
    
    dispatch_sync(_internalSerialQueue, ^{
        allKeys = [_internalDictionary allKeys];
    });
    
    NSArray *allKeyCopys = [[NSArray alloc] initWithArray:allKeys];
    
    return allKeyCopys;
}

@end
