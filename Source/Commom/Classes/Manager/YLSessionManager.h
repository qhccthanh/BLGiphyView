//
//  YLSessionManager.h
//  YALO
//
//  Created by BaoNQ on 7/15/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMutableDictionary.h"
#import "int_type.h"

typedef void(^YLSessionGetTasksCompletionHandler)(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks);

@interface YLSessionManager : NSObject

/**
 *  Singletion method of image caching.
 */
+ (id)sharedDefaultSessionManager;

/**
The managed session.
 */
@property (readonly, nonatomic, strong) NSURLSession *session;

/**
 The operation queue on which delegate callbacks are run.
 */
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

/**
 The data tasks currently run by the managed session.
 */
@property (readonly, nonatomic, strong) TSMutableDictionary *dataTasks;

/**
 The upload tasks currently run by the managed session.
 */
@property (readonly, nonatomic, strong) TSMutableDictionary *uploadTasks;

/**
 The download tasks currently run by the managed session.
 */
@property (readonly, nonatomic, strong) TSMutableDictionary *downloadTasks;


/**
 Creates and returns a manager for a session created with the specified configuration.
 
 @param configuration The configuration used to create the managed session.
 
 @return A manager for a new session.
 */
- (id)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 *  Asynchronously calls a completion callback with all data, upload, and download tasks in a session.
    The returned arrays contain any tasks that you have created within the session, not including any tasks
    that have been invalidated after completing, failing, or being cancelled.
 *
 *  @param completionBlock The completion handler to call with the list of tasks. This handler is executed on the delegate queue.
 */
- (void)getTasksWithCompletionHandler:(YLSessionGetTasksCompletionHandler)completionBlock;

/**
 *  Start a data task with a given URL. This task will be identified by taskIdentifier.
 *
 *  @param url               The URL to be retrieved.
 *  @param completionHandler The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
 *
 *  @return This task will be add to a dictionary with this identifier. The dictionary is managed by YLSessionManager.
 */
- (INTEGER_T)startDataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionBlock;

/**
 *  Cancel a data task associated with a given identifier.
    This function is executed in a internal serial queue and it support threads safe.
    If no data task associated with the identifier, it do nothing.
 *
 *  @param taskIdentifier The task identifier to cancel.
 */
- (void)cancelDataTaskWithIdentifier:(INTEGER_T)taskIdentifier;

/**
 *  Cancels all outstanding tasks and then invalidates the session.
    Once invalidated, references to the delegate and callback objects are broken. 
    After invalidation, session objects cannot be reused.
 */
- (void)invalidateSessionAndCancelTasks;

/**
 *  Invalidates the session, allowing any outstanding tasks to finish.
 This method returns immediately without waiting for tasks to finish.
 Once a session is invalidated, new tasks cannot be created in the session, but existing tasks continue until completion.
 */
- (void)finishTasksAndInvalidateSession;

/**
 *  Generate a sequence data task identifier
 *
 *  @return The data task identifier has generated
 */
- (INTEGER_T)generateTaskIdentifier;

/**
 *  Start a data task with a given URL with data task
 *
 *  @param url             The URL to be retrieved.
 *  @param taskIdentifier  The task identifier has generate by generateTaskIdentifier method
 *  @param completionBlock The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
 */
- (void)startDataTaskWithURL:(NSURL *)url taskIdentifier:(INTEGER_T)taskIdentifier completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionBlock;

/**
 *  Remove all current data task
 */
- (void)cancelAllDataTask;

@end
