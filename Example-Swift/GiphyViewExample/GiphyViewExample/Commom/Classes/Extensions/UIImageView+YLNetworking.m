//
//  UIImageView+YLNetworking.m
//  YALO
//
//  Created by BaoNQ on 8/8/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "UIImageView+YLNetworking.h"
#import <objc/runtime.h>
#import "int_type.h"
#import "YLImageCache.h"



@implementation UIImageView (_YLNetworking)

- (INTEGER_T)activeImageDownloadIdentifier {
#if __64bit__
    return (INTEGER_T)[objc_getAssociatedObject(self, @selector(activeImageDownloadIdentifier)) longLongValue];
#else
    return (INTEGER_T)[objc_getAssociatedObject(self, @selector(activeImageDownloadIdentifier)) intValue];
#endif
}

- (void)setActiveImageDownloadIdentifier:(INTEGER_T)imageDownloadIdentifier {
#if __64bit__
    objc_setAssociatedObject(self, @selector(activeImageDownloadIdentifier), [NSNumber numberWithLongLong:imageDownloadIdentifier], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#else
    objc_setAssociatedObject(self, @selector(activeImageDownloadIdentifier), [NSNumber numberWithInt:imageDownloadIdentifier], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
}

- (NSString *)activeImageURL {
    return objc_getAssociatedObject(self, @selector(activeImageURL));
}

- (void)setActiveImageURL:(NSString *)activeImageURL {
    objc_setAssociatedObject(self, @selector(activeImageURL), activeImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (YLNetworking)

//- (void)setActiveImageURL:(NSString *)activeImageURL {
//    objc_setAssociatedObject(self, @selector(activeImageURL), activeImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (INTEGER_T)activeImageDownloadIdentifier {
//#if __64bit__
//    return (INTEGER_T)[objc_getAssociatedObject(self, @selector(activeImageDownloadIdentifier)) longLongValue];
//#else
//    return (INTEGER_T)[objc_getAssociatedObject(self, @selector(activeImageDownloadIdentifier)) intValue];
//#endif
//}
//
//- (void)setActiveImageDownloadIdentifier:(INTEGER_T)imageDownloadIdentifier {
//#if __64bit__
//    objc_setAssociatedObject(self, @selector(activeImageDownloadIdentifier), [NSNumber numberWithLongLong:imageDownloadIdentifier], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//#else
//    objc_setAssociatedObject(self, @selector(activeImageDownloadIdentifier), [NSNumber numberWithInt:imageDownloadIdentifier], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//#endif
//}

+ (YLImageDownloader *)sharedImageDownloader {
    return objc_getAssociatedObject(self, @selector(sharedImageDownloader)) ? : [YLImageDownloader sharedDefaultImageDownloader];
}

+ (void)setSharedImageDownloader:(YLImageDownloader *)imageDownloader {
    objc_setAssociatedObject(self, @selector(sharedImageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
             identifier:(NSString *)imageIdentifier {
    
    [self setImageWithURL:url placeholderImage:placeholderImage identifier:imageIdentifier cancelExistedTask:NO success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
             identifier:(NSString *)imageIdentifier
      cancelExistedTask:(BOOL)shouldCancel
                success:(void (^)(NSURLResponse *response, UIImage *image))success
                failure:(void (^)(NSURLResponse *response, NSError *error))failure {
    
    if (url == nil) {
        [self cancelImageDownloadTask];
        if (placeholderImage)
            self.image = placeholderImage;
        return;
    }
    
    if ([self isActiveTaskURLEqualToURL:url]){
        return;
    }
    
    if (shouldCancel)
        [self cancelImageDownloadTask];
    
    UIImage *cachedImage = [[YLImageCache sharedCachedImage] imageForKey:imageIdentifier];
    
    if (cachedImage) {
        if (success) {
            success(nil, cachedImage);
        }
        else {
            self.image = cachedImage;
        }
    }
    else {
        if (placeholderImage)
            self.image = placeholderImage;
        
        self.activeImageURL = url.absoluteString;
        
        YLImageDownloader *imageDownloader = [self.class sharedImageDownloader];
        
        __weak __typeof(self)weakSelf = self;

        INTEGER_T dataTaskID = [imageDownloader downloadImageWithURL:url identifier:imageIdentifier completionHandler:^(id imageIdentifier, UIImage *image, NSURLResponse *response, NSError *error) {
            if (weakSelf.activeImageDownloadIdentifier == dataTaskID) {
                if (error) {
                    if (failure) {
                        failure(response, error);
                    }
                }
                else {
                    if (success) {
                        success(response, image);
                    }
                    else if (image) {
                        weakSelf.image = image;
                    }
                }
                weakSelf.activeImageURL = @"";
            }
        }];
        self.activeImageDownloadIdentifier = dataTaskID;
    }
}

- (void)cancelImageDownloadTask {
    if (self.activeImageURL == nil)
        return;
    
    if (![self.activeImageURL isEqualToString:@""]) {
        [[self.class sharedImageDownloader] cancelDataTaskWithIdentifier:self.activeImageDownloadIdentifier];
        
        self.activeImageURL = @"";
    }
}

- (BOOL)isActiveTaskURLEqualToURL:(NSURL *)url {
    return [[self activeImageURL] isEqualToString:url.absoluteString];
}

@end
