//
//  UIImageView+YLNetworking.h
//  YALO
//
//  Created by BaoNQ on 8/8/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLImageDownloader.h"

@interface UIImageView (_YLNetworking)

@property (nonatomic) INTEGER_T activeImageDownloadIdentifier;
@property (nonatomic, strong) NSString *activeImageURL;

@end

/**
 This category adds methods to the UIKit framework's `UIImageView` class. The methods in this category provide support for loading remote images asynchronously from a URL.
 */
@interface UIImageView (YLNetworking)

/**
 Set the shared image downloader used to download images.
 
 @param imageDownloader The shared image downloader used to download images.
 */
+ (void)setSharedImageDownloader:(YLImageDownloader *)imageDownloader;

/**
 The shared image downloader used to download images.
 */
+ (YLImageDownloader *)sharedImageDownloader;

/**
 Asynchronously downloads an image from the specified URL request, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
The default behavior of setting the image with `self.image = image` is applied automatically.
 
 @param urlRequest          The URL request used for the image request.
 @param placeholderImage    The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param identifier          The downloaded image will be cached by this identifier. The cache is managed by YLImageCache.
*/
- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
             identifier:(NSString *)imageIdentifier;

/**
 Asynchronously downloads an image from the specified URL request, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the image view before returning. If no success block is specified, the default behavior of setting the image with `self.image = image` is applied.
 
 @param urlRequest          The URL request used for the image request.
 @param placeholderImage    The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param identifier          The downloaded image will be cached by this identifier. The cache is managed by YLImageCache.
 @param cancelExistedTask   YES if you want to cancel the existed task, otherwise, pass NO.
 @param success             A block to be executed when the image data task finishes successfully. 
                            This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the response parameter will be `nil`.
 @param failure             A block object to be executed when the image data task finishes unsuccessfully, or that finishes successfully. 
                            This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
             identifier:(NSString *)imageIdentifier
      cancelExistedTask:(BOOL)shouldCancel
                success:(void (^)(NSURLResponse *response, UIImage *image))success
                failure:(void (^)(NSURLResponse *response, NSError *error))failure;

/**
    Cancels any executing image operation for the receiver, if one exists.
 */
- (void)cancelImageDownloadTask;

/**
 *  Check UIImageVIew is active with URL
 *
 *  @return The boolean check is active with URL
 */
- (BOOL)isActiveTaskURLEqualToURL:(NSURL *)url;

//- (void)setActiveImageURL:(NSString *)activeImageURL;

//- (INTEGER_T)activeImageDownloadIdentifier;

//- (void)setActiveImageDownloadIdentifier:(INTEGER_T)imageDownloadIdentifier;

@end
