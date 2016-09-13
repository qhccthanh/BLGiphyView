//
//  YLSessionManager.m
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "YLSessionManager.h"
#include <libkern/OSAtomic.h>

@interface YLSessionManager ()

@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) TSMutableDictionary *dataTasks;
@property (readwrite, nonatomic, strong) TSMutableDictionary *uploadTasks;
@property (readwrite, nonatomic, strong) TSMutableDictionary *downloadTasks;
@property (nonatomic, strong) dispatch_queue_t internalSerialQueue;

@property volatile INTEGER_T identifier;

@end

@implementation YLSessionManager

//Singleton Method
+ (id)sharedDefaultSessionManager {
    
    static YLSessionManager *defaultCachedImage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultCachedImage = [[self alloc] init];
    });
    
    return defaultCachedImage;
}

- (id)init {
    return [self initWithSessionConfiguration:nil];
}

- (id)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    self.sessionConfiguration = configuration;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:(id<NSURLSessionDelegate>)self delegateQueue:self.operationQueue];
    
    _dataTasks = [[TSMutableDictionary alloc] init];
    _uploadTasks = [[TSMutableDictionary alloc] init];
    _downloadTasks = [[TSMutableDictionary alloc] init];
    
    _internalSerialQueue = dispatch_queue_create("com.yalo.serialQueue", NULL);
    
    _identifier = 0;
    
    return self;
}

- (void)getTasksWithCompletionHandler:(YLSessionGetTasksCompletionHandler)completionBlock {
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        completionBlock(dataTasks, uploadTasks, downloadTasks);
    }];
}

- (INTEGER_T)generateTaskIdentifier {
    INTEGER_T identifier;
#if __64bit__
    if (identifier == LONG_LONG_MAX)
        identifier = 0;
    else
        identifier = OSAtomicIncrement64Barrier(&_identifier);
#else
    if (identifier == INT_MAX)
        identifier = 0;
    else
        identifier = OSAtomicIncrement32Barrier(&_identifier);
#endif
    return identifier;
}

- (void)startDataTaskWithURL:(NSURL *)url taskIdentifier:(INTEGER_T)taskIdentifier completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionBlock {
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionBlock) {
            completionBlock(data, response, error);
        }
        // After this task is executed, remove it from list.
        [_dataTasks removeObjectForKey:[NSNumber numberWithUnsignedLongLong:_identifier]];
    }];
    // Add data task to dataTasks list.
    if (dataTask) {
#if __64bit__
        [_dataTasks setObject:dataTask forKey:[NSNumber numberWithLongLong:taskIdentifier]];
#else
        [_dataTasks setObject:dataTask forKey:[NSNumber numberWithInt:taskIdentifier]];
#endif
    }
    
    [dataTask resume];
    
}

- (INTEGER_T)startDataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionBlock {
    
#if __64bit__
    if (_identifier == LONG_LONG_MAX)
        _identifier = 0;
    else
        _identifier = OSAtomicIncrement64Barrier(&_identifier);
#else
    if (_identifier == INT_MAX)
        _identifier = 0;
    else
        _identifier = OSAtomicIncrement32Barrier(&_identifier);
#endif
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionBlock) {
            completionBlock(data, response, error);
        }
        // After this task is executed, remove it from list.
        [_dataTasks removeObjectForKey:[NSNumber numberWithUnsignedLongLong:_identifier]];
    }];
    // Add data task to dataTasks list.
    if (dataTask) {
#if __64bit__
        [_dataTasks setObject:dataTask forKey:[NSNumber numberWithLongLong:_identifier]];
#else
        [_dataTasks setObject:dataTask forKey:[NSNumber numberWithInt:_identifier]];
#endif
    }
    
    [dataTask resume];

    return _identifier;
}

- (void)cancelDataTaskWithIdentifier:(INTEGER_T)taskIdentifier {
    
    dispatch_sync(_internalSerialQueue, ^{
        NSNumber *identifier;
#if __64bit__
        identifier = [NSNumber numberWithLongLong:_identifier];
#else
        identifier = [NSNumber numberWithInt:_identifier];
#endif
        
        NSURLSessionDataTask *dataTask = [self.dataTasks objectForKey:identifier];
        
        if (dataTask) {
            // Remove this task from the list
            [self.dataTasks removeObjectForKey:identifier];
            
            [dataTask cancel];
        }
    });
}

- (void)cancelAllDataTask {
    
    dispatch_sync(_internalSerialQueue, ^{
        id allKeys = self.dataTasks.allKeys;
        
        for (NSString* key in allKeys) {
            NSURLSessionDataTask* dataTask = [self.dataTasks objectForKey:key];
            [dataTask cancel];
        }
        
        [self.dataTasks removeAllObjects];
        
    });
    
}

- (void)invalidateSessionAndCancelTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session invalidateAndCancel];
    });
}

- (void)finishTasksAndInvalidateSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session finishTasksAndInvalidate];
    });
}

@end
