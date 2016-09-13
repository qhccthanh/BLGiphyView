//
//  YLImageDownloader.h
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSessionManager.h"
#import <UIKit/UIKit.h>

typedef void(^DownloadImageWithURLCompletionHandler)(id imageIdentifier, UIImage * image , NSURLResponse * response,  NSError * error);
typedef void(^DownloadGIFWithURLCompletionHandler)(INTEGER_T taskID, id imageIdentifier, UIImage * image , NSURLResponse * response,  NSError * error);

@interface YLImageDownloader : NSObject

@property (readonly, nonatomic, strong) YLSessionManager *sessionManager;

/**
 *  The shared default instance of `YLImageDownloader` initialized with default values.
 */
+ (id)sharedDefaultImageDownloader;

/**
 *  Init with a given session manager.
 */
- (id)initWithSessionManager:(YLSessionManager *)sessionManager;

/**
 *  Download image with a given URL
    This function will be called asynchronize with a completion block.
 *
 *  @param url                  The URL to be retrieved.
 *  @param imageIdentifier      The downloaded image will be add to YLImageCache by this identifier.
 *  @param completionBlock      A DownloadImageWithURLCompletionHandler block.
 *
 *  @return This task will be add to a dictionary with this identifier. The dictionary is managed by YLSessionManager.
 */
- (INTEGER_T)downloadImageWithURL:(NSURL *)url identifier:(NSString *)imageIdentifier completionHandler:(DownloadImageWithURLCompletionHandler)completionBlock;

/**
 *  Download image with a given URL
 This function will be called asynchronize with a completion block.
 *
 *  @param url                  The URL to be retrieved.
 *  @param imageIdentifier      The downloaded image will be add to YLImageCache by this identifier.
 *  @param completionBlock      A DownloadImageWithURLCompletionHandler block.
 *
 *  @return This task will be add to a dictionary with this identifier. The dictionary is managed by YLSessionManager.
 */
- (void)downloadImageWithURL:(NSURL *)url taskIdentifier:(INTEGER_T)taskIdentifier identifier:(NSString *)imageIdentifier completionHandler:(DownloadImageWithURLCompletionHandler)completionBlock;

- (INTEGER_T)generateTaskIdentifier;

/**
 *  Cancel a image download task associated with a given identifier.
    This function is executed in a internal serial queue and it support threads safe.
    If no mage download task associated with the identifier, it do nothing.
 *
 *  @param taskIdentifier The task identifier to cancel.
 */
- (void)cancelDataTaskWithIdentifier:(INTEGER_T)taskIdentifier;

/**
 *  Cancel all Datatask
 */
- (void)cancelAllDataTask;

@end
