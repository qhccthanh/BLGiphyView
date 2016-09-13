//
//  YLImageDownloader.m
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "YLImageDownloader.h"
#import "YLImageCache.h"

@interface YLImageDownloader ()

@property (readwrite, nonatomic, strong) YLSessionManager *sessionManager;
@property (nonatomic, strong) dispatch_queue_t internalSerialQueue;

@end

@implementation YLImageDownloader

+ (id)sharedDefaultImageDownloader {
    static YLImageDownloader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    // Create a session manager use defaultSessionConfiguration.
    self.sessionManager = [[YLSessionManager alloc] init];
    _internalSerialQueue = dispatch_queue_create("com.yalo.serialQueue", NULL);

    return self;
}

- (id)initWithSessionManager:(YLSessionManager *)sessionManager {
    self = [super init];
    if (!self)
        return nil;
    
    self.sessionManager = sessionManager;
    
    return self;
}

- (INTEGER_T)downloadImageWithURL:(NSURL *)url identifier:(NSString *)imageIdentifier completionHandler:(DownloadImageWithURLCompletionHandler)completionBlock {
    
    INTEGER_T taskIdentifier = [self.sessionManager startDataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        UIImage *downloadedImage = nil;
        if (!error) {
            downloadedImage = [UIImage imageWithData:data];
            // Cache image.
            if (imageIdentifier)
                [[YLImageCache sharedCachedImage] cacheImage:downloadedImage forKey:imageIdentifier];
        }
        if (completionBlock)
            completionBlock(imageIdentifier, downloadedImage, response, error);
    }];
    return taskIdentifier;
}

- (void)cancelDataTaskWithIdentifier:(INTEGER_T)taskIdentifier {
    [self.sessionManager cancelDataTaskWithIdentifier:taskIdentifier];
}

- (void)cancelAllDataTask {
    [self.sessionManager cancelAllDataTask];
}

- (void)downloadImageWithURL:(NSURL *)url taskIdentifier:(INTEGER_T)taskIdentifier identifier:(NSString *)imageIdentifier completionHandler:(DownloadImageWithURLCompletionHandler)completionBlock {
    [self.sessionManager startDataTaskWithURL:url taskIdentifier:taskIdentifier completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        UIImage *downloadedImage = nil;
        if (!error) {
            downloadedImage = [UIImage imageWithData:data];
            // Cache image.
            if (imageIdentifier)
                [[YLImageCache sharedCachedImage] cacheImage:downloadedImage forKey:imageIdentifier];
        }
        if (completionBlock)
            completionBlock(imageIdentifier, downloadedImage, response, error);
    }];

}

- (INTEGER_T)generateTaskIdentifier {
    INTEGER_T taskIdentifier = [self.sessionManager generateTaskIdentifier];
    return taskIdentifier;
}

@end
