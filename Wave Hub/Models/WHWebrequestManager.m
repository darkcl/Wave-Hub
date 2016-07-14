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
            
            SCLoginViewController *loginViewController;
            loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                          completionHandler:^(NSError *error){
                                                                              
                                                                              if (SC_CANCELED(error)) {
                                                                                  NSLog(@"Canceled!");
                                                                                  failureBlock(error);
                                                                              } else if (error) {
                                                                                  NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                                                                  failureBlock(error);
                                                                              } else {
                                                                                  NSLog(@"Done!");
                                                                                  successBlock(nil);
                                                                              }
                                                                          }];
            
            [viewController presentViewController:loginViewController
                                         animated:YES
                                       completion:nil];
            
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

- (MyFavourite *)mergeFavourite:(MyFavourite *)obj1
                    toFavourite:(MyFavourite *)obj2{
    if (obj1 == nil) {
        return obj2;
    }else{
        NSMutableArray *collections = [[NSMutableArray alloc] initWithArray:obj1.collection];
        [collections addObjectsFromArray:obj2.collection];
        
        MyFavourite *result = [[MyFavourite alloc] init];
        
        result.collection = collections;
        result.nextHref = obj2.nextHref;
        NSLog(@"Next Href: %@", result.nextHref);
        return result;
    }
}

- (void)fetchAllFavouriteWithInfo:(MyFavourite *)info
                          success:(RequestSuccess)successBlock
                             failure:(RequestFailure)failureBlock{
    NSString *url;
    if (info != nil) {
        if (info.nextHref != nil && info.nextHref.length != 0) {
            url = info.nextHref;
        }else{
            successBlock(info);
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
                         MyFavourite *favourites = [MyFavourite modelObjectWithDictionary:aDict];
                         MyFavourite *result = [self mergeFavourite:info toFavourite:favourites];
                         [self fetchAllFavouriteWithInfo:result
                                                 success:successBlock
                                                 failure:failureBlock];
                     }
                 }
             }];
}

- (void)fetchMyFavouriteWithInfo:(MyFavourite *)info
                         success:(RequestSuccess)successBlock
                         failure:(RequestFailure)failureBlock{
    NSString *url;
    if (info != nil) {
        if (info.nextHref != nil && info.nextHref.length != 0) {
            url = info.nextHref;
        }else{
            NSError *error = [NSError errorWithDomain:@"WebRequestError"
                                                 code:0
                                             userInfo:@{NSLocalizedDescriptionKey : @"No more favourites."}];
            
            failureBlock(error);
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
                         MyFavourite *favourites = [MyFavourite modelObjectWithDictionary:aDict];
                         
                         if (info != nil) {
                             NSMutableArray *collections = [[NSMutableArray alloc] initWithArray:info.collection];
                             [collections addObjectsFromArray:favourites.collection];
                             info.collection = collections;
                             info.nextHref = favourites.nextHref;
                             successBlock(info);
                         }else{
                             successBlock(favourites);
                         }
                     }
                 }
             }];
}

- (void)streamCollection:(Collection *)collectionInfo
                 success:(RequestSuccess)successBlock
                 failure:(RequestFailure)failureBlock{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.wav",
                          documentsDirectory, collectionInfo.uri.lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:nil]) {
        NSURL *url = [NSURL URLWithString:fileName];
        successBlock(url);
    }else{
        [SVProgressHUD show];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSLog(@"Start Loading");
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
        localNotification.alertBody = [NSString stringWithFormat:@"Start Loading for song: %@", collectionInfo.title];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:collectionInfo.streamUrl]
                 usingParameters:nil
                     withAccount:[SCSoundCloud account]
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                     [SVProgressHUD dismiss];
                     NSLog(@"End Loading");
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     if (!error) {
                         [data writeToFile:fileName atomically:YES];
                         NSURL *url = [NSURL URLWithString:fileName];
                         successBlock(url);
                     }else{
                         failureBlock(error);
                         UILocalNotification* localNotification2 = [[UILocalNotification alloc] init];
                         localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
                         localNotification2.alertBody = [NSString stringWithFormat:@"Error Loading for song: %@", collectionInfo.title];
                         localNotification2.timeZone = [NSTimeZone defaultTimeZone];
                         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification2];
                     }
                 }];
        
    }
}

@end
