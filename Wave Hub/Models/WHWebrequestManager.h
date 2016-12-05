//
//  WHWebrequestManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestSuccess)(id responseObject);
typedef void(^RequestFailure)(NSError *error);

@class AFHTTPRequestOperationManager;

@interface WHWebrequestManager : NSObject{
    AFHTTPRequestOperationManager *apiManager;
}

+ (instancetype)sharedManager;

- (void)loginToSoundCloud:(RequestSuccess)successBlock
                  failure:(RequestFailure)failureBlock
       withViewController:(UIViewController *)viewController;

- (void)fetchMyPlaylistWithInfo:(id)info
                        success:(RequestSuccess)successBlock
                        failure:(RequestFailure)failureBlock;


// Will remove
- (void)fetchAllFavouriteWithInfo:(NSDictionary *)info
                          success:(RequestSuccess)successBlock
                          failure:(RequestFailure)failureBlock;

// Will remove
- (void)fetchUserInfoWithUserId:(NSString *)userId
                        success:(RequestSuccess)successBlock
                        failure:(RequestFailure)failureBlock;

// Will remove
- (void)fetchTracksForUserId:(NSString *)userId
                        info:(NSDictionary *)info
                     success:(RequestSuccess)successBlock
                     failure:(RequestFailure)failureBlock;

- (void)followUserId:(NSString *)userId
             success:(RequestSuccess)successBlock
             failure:(RequestFailure)failureBlock;

- (void)unfollowUserId:(NSString *)userId
             success:(RequestSuccess)successBlock
             failure:(RequestFailure)failureBlock;

- (void)fetchIsFollowUserId:(NSString *)userId
             success:(RequestSuccess)successBlock
             failure:(RequestFailure)failureBlock;

#pragma mark - Pagination
/**
 *  Fetch My favourites
 *
 *  @param url          Resource Url
 *  @param successBlock Return array of WHTrackModel (current page), if have next page, last object will be a placeholder
 *  @param failureBlock Error call back
 */
- (void)fetchTracksWithUrl:(NSString *)url
                   success:(RequestSuccess)successBlock
                   failure:(RequestFailure)failureBlock;

@end
