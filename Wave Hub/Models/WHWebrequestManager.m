//
//  WHWebrequestManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "WHWebrequestManager.h"
#import <JRNLocalNotificationCenter/JRNLocalNotificationCenter.h>

#import "WHActivityModel.h"

static NSString * const kBaseURL = @"https://api.soundcloud.com";

@interface WHWebrequestManager ()

@end

@implementation WHWebrequestManager

+ (instancetype)sharedManager
{
    static WHWebrequestManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init{
    if (self = [super init]) {
        apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [SCSoundCloud  setClientID:@"47724625bbc02bbc335e84f2ed87c001"
                            secret:@"8614d82e8d7e8f90c91ec144aec29986"
                       redirectURL:[NSURL URLWithString:@"wavehub://oauth"]];
    }
    return self;
}

- (void)loginToSoundCloud:(RequestSuccess)successBlock
                  failure:(RequestFailure)failureBlock
       withViewController:(UIViewController *)viewController{
    if ([SCSoundCloud account]) {
        successBlock(nil);
    }else{
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            
            UINavigationController *loginViewController;
            loginViewController = (UINavigationController *)[SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                          completionHandler:^(NSError *error){
                                                                              
                                                                              if (SC_CANCELED(error)) {
                                                                                  NSLog(@"Canceled!");
                                                                                  failureBlock(error);
                                                                                  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                                                                              } else if (error) {
                                                                                  NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                                                                  failureBlock(error);
                                                                                  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                                                                              } else {
                                                                                  NSLog(@"Done!");
                                                                                  successBlock(nil);
                                                                                  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                                                                              }
                                                                          }];
            
            [viewController presentViewController:loginViewController
                                         animated:YES
                                       completion:^{
                                           [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                                       }];
            
        }];
    }
}

- (void)fetchMyPlaylistWithInfo:(id)info
                        success:(RequestSuccess)successBlock
                        failure:(RequestFailure)failureBlock{
    NSString *url = @"https://api.soundcloud.com/me/playlists";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:@{@"linked_partitioning":@"1"}
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

- (NSDictionary *)mergeFavourite:(NSDictionary *)obj1
                    toFavourite:(NSDictionary *)obj2{
    if (obj1 == nil) {
        return obj2;
    }else{
        NSMutableArray *collections = [[NSMutableArray alloc] initWithArray:obj1[@"collection"]];
        [collections addObjectsFromArray:obj2[@"collection"]];
        NSDictionary *result;
        if (obj2[@"next_href"]!=nil) {
            result = @{@"next_href": obj2[@"next_href"],
                       @"collection": collections};
        }else{
            result = @{@"collection": collections};
        }
        
        NSLog(@"Next Href: %@", obj2[@"next_href"]);
        return result;
    }
}

- (void)fetchTracksForUserId:(NSString *)userId
                        info:(NSDictionary *)info
                          success:(RequestSuccess)successBlock
                          failure:(RequestFailure)failureBlock{
    NSString *url = info[@"next_href"];
    if (info != nil) {
        if (url != nil && url.length != 0) {
            url = info[@"next_href"];
        }else{
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            for (NSDictionary *trackInfo in info[@"collection"]) {
                WHTrackModel *aTrack = [[WHTrackModel alloc] initWithInfo:trackInfo];
                aTrack.trackType = WHTrackTypeSoundCloud;
                [result addObject:aTrack];
            }
            
            successBlock(result);
            return;
        }
    }else{
        url = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks", userId];
    }
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:@{@"linked_partitioning":@"1"}
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         NSDictionary *result = [self mergeFavourite:info toFavourite:aDict];
                         [self fetchTracksForUserId:userId
                                               info:result
                                            success:successBlock
                                            failure:failureBlock];
                     }
                 }
             }];
}

- (void)fetchAllFavouriteWithInfo:(NSDictionary *)info
                          success:(RequestSuccess)successBlock
                             failure:(RequestFailure)failureBlock{
    NSString *url = info[@"next_href"];
    if (info != nil) {
        if (url != nil && url.length != 0) {
            url = info[@"next_href"];
        }else{
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            for (NSDictionary *trackInfo in info[@"collection"]) {
                WHTrackModel *aTrack = [[WHTrackModel alloc] initWithInfo:trackInfo];
                aTrack.trackType = WHTrackTypeSoundCloud;
                [result addObject:aTrack];
            }
            
            successBlock(result);
            return;
        }
    }else{
        url = @"https://api.soundcloud.com/me/favorites";
    }
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:@{@"linked_partitioning":@"1"}
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         NSDictionary *result = [self mergeFavourite:info toFavourite:aDict];
                         [self fetchAllFavouriteWithInfo:result
                                                 success:successBlock
                                                 failure:failureBlock];
                     }
                 }
             }];
}

- (void)fetchTracksWithUrl:(NSString *)url
                    success:(RequestSuccess)successBlock
                    failure:(RequestFailure)failureBlock{
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:requestUrl
             usingParameters:@{@"linked_partitioning":@"1"}
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         NSMutableArray *result = [[NSMutableArray alloc] init];
                         
                         for (NSDictionary *trackInfo in aDict[@"collection"]) {
                             NSDictionary *infoDict = trackInfo;
                             
                             if (trackInfo[@"origin"] != nil) {
                                 infoDict = trackInfo[@"origin"];
                                 
                                 if (![infoDict[@"kind"] isEqualToString:@"playlist"]) {
                                     WHTrackModel *aTrack = [[WHTrackModel alloc] initWithInfo:infoDict];
                                     aTrack.trackType = WHTrackTypeSoundCloud;
                                     [result addObject:aTrack];
                                 }
                             }else{
                                 WHTrackModel *aTrack = [[WHTrackModel alloc] initWithInfo:infoDict];
                                 aTrack.trackType = WHTrackTypeSoundCloud;
                                 [result addObject:aTrack];
                             }
                             
                             
                         }
                         
                         NSString *nextHref = aDict[@"next_href"];
                         
                         if (nextHref != nil) {
                             [result addObject:[[WHTrackModel alloc] initWithNextHref:nextHref]];
                         }
                         
                         successBlock(result);
                     }
                 }
             }];
}

- (void)followUserId:(NSString *)userId
             success:(RequestSuccess)successBlock
             failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/followings/%@", userId];
    
    [SCRequest performMethod:SCRequestMethodPUT
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

- (void)unfollowUserId:(NSString *)userId
               success:(RequestSuccess)successBlock
               failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/followings/%@", userId];
    
    [SCRequest performMethod:SCRequestMethodDELETE
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

- (void)fetchIsFollowUserId:(NSString *)userId
                    success:(RequestSuccess)successBlock
                    failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/followings/%@", userId];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     successBlock(@NO);
                     
                 }else{
                     successBlock(@YES);
                 }
             }];
}

#pragma mark - Like

- (void)favouriteTrack:(NSString *)trackId
               success:(RequestSuccess)successBlock
               failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", trackId];
    
    [SCRequest performMethod:SCRequestMethodPUT
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

- (void)unfavouriteTrack:(NSString *)trackId
                 success:(RequestSuccess)successBlock
                 failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", trackId];
    
    [SCRequest performMethod:SCRequestMethodDELETE
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

- (void)fetchIsFavouriteWithTrackId:(NSString *)trackId
                            success:(RequestSuccess)successBlock
                            failure:(RequestFailure)failureBlock{
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", trackId];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     successBlock(@NO);
                     
                 }else{
                     successBlock(@YES);
                 }
             }];
}

#pragma mark - Dashboard (Activity)

- (void)fetchActivityWithUrl:(NSString *)url
                     success:(RequestSuccess)successBlock
                     failure:(RequestFailure)failureBlock{
    NSURL *resourceUrl;
    
    if(url == nil){
        resourceUrl = [NSURL URLWithString:@"https://api.soundcloud.com/me/activities/tracks"];
    }else{
        resourceUrl = [NSURL URLWithString:url];
    }
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:resourceUrl
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 
                 if (error) {
                     failureBlock(error);
                 }else{
                     NSError *jsonError;
                     NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                     
                     if (jsonError != nil) {
                         failureBlock(jsonError);
                     }else{
                         NSMutableArray *result = [[NSMutableArray alloc] init];
                         
                         for (NSDictionary *infoDict in jsonDict[@"collection"]) {
                             WHTrackModel *anActivity = [[WHTrackModel alloc] initWithInfo:infoDict[@"origin"]];
                             [result addObject:anActivity];
                         }
                         
                         NSString *nextHref = jsonDict[@"next_href"];
                         
                         if (nextHref != nil) {
                             [result addObject:[[WHTrackModel alloc] initWithNextHref:nextHref]];
                         }
                         
                         successBlock([NSArray arrayWithArray:result]);
                     }
                 }
             }];
}

//- (void)fetchMyFavouriteWithInfo:(MyFavourite *)info
//                         success:(RequestSuccess)successBlock
//                         failure:(RequestFailure)failureBlock{
//    NSString *url;
//    if (info != nil) {
//        if (info.nextHref != nil && info.nextHref.length != 0) {
//            url = info.nextHref;
//        }else{
//            NSError *error = [NSError errorWithDomain:@"WebRequestError"
//                                                 code:0
//                                             userInfo:@{NSLocalizedDescriptionKey : @"No more favourites."}];
//            
//            failureBlock(error);
//            return;
//        }
//    }else{
//        url = @"https://api.soundcloud.com/me/favorites";
//    }
//    
//    [SCRequest performMethod:SCRequestMethodGET
//                  onResource:[NSURL URLWithString:url]
//             usingParameters:@{@"linked_partitioning":@"1"}
//                 withAccount:[SCSoundCloud account]
//      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
//          
//      }
//             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
//                 if (error) {
//                     failureBlock(error);
//                     
//                 }else{
//                     NSError *jsonError;
//                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
//                                                                           options:NSJSONReadingAllowFragments
//                                                                             error:&jsonError];
//                     if (jsonError) {
//                         failureBlock(jsonError);
//                     }else{
//                         MyFavourite *favourites = [MyFavourite modelObjectWithDictionary:aDict];
//                         
//                         if (info != nil) {
//                             NSMutableArray *collections = [[NSMutableArray alloc] initWithArray:info.collection];
//                             [collections addObjectsFromArray:favourites.collection];
//                             info.collection = collections;
//                             info.nextHref = favourites.nextHref;
//                             successBlock(info);
//                         }else{
//                             successBlock(favourites);
//                         }
//                     }
//                 }
//             }];
//}

//- (void)streamCollection:(Collection *)collectionInfo
//                 success:(RequestSuccess)successBlock
//                 failure:(RequestFailure)failureBlock{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains
//    (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    //make a file name to write the data to using the documents directory:
//    NSString *fileName = [NSString stringWithFormat:@"%@/%@.wav",
//                          documentsDirectory, collectionInfo.uri.lastPathComponent];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:nil]) {
//        NSURL *url = [NSURL URLWithString:fileName];
//        successBlock(url);
//    }else{
//        [SVProgressHUD show];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//        NSLog(@"Start Loading");
//        
//        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
//        localNotification.alertBody = [NSString stringWithFormat:@"Start Loading for song: %@", collectionInfo.title];
//        localNotification.timeZone = [NSTimeZone defaultTimeZone];
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//        
//        [SCRequest performMethod:SCRequestMethodGET
//                      onResource:[NSURL URLWithString:collectionInfo.streamUrl]
//                 usingParameters:nil
//                     withAccount:[SCSoundCloud account]
//          sendingProgressHandler:nil
//                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                     [SVProgressHUD dismiss];
//                     NSLog(@"End Loading");
//                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//                     if (!error) {
//                         [data writeToFile:fileName atomically:YES];
//                         NSURL *url = [NSURL URLWithString:fileName];
//                         successBlock(url);
//                     }else{
//                         failureBlock(error);
//                         UILocalNotification* localNotification2 = [[UILocalNotification alloc] init];
//                         localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
//                         localNotification2.alertBody = [NSString stringWithFormat:@"Error Loading for song: %@", collectionInfo.title];
//                         localNotification2.timeZone = [NSTimeZone defaultTimeZone];
//                         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification2];
//                     }
//                 }];
//        
//    }
//}

- (void)fetchUserInfoWithUserId:(NSString *)userId
                        success:(RequestSuccess)successBlock
                        failure:(RequestFailure)failureBlock{
    
    NSString *url = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@",userId];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
          
      }
             responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                 if (error) {
                     failureBlock(error);
                     
                 }else{
                     NSError *jsonError;
                     NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:&jsonError];
                     if (jsonError) {
                         failureBlock(jsonError);
                     }else{
                         
                         successBlock(aDict);
                     }
                 }
             }];
}

@end
