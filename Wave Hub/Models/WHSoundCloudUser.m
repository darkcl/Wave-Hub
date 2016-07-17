//
//  WHSoundCloudUser.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "WHSoundCloudUser.h"

@implementation WHSoundCloudUser

- (id)initWithUserInfo:(NSDictionary *)dict{
    if (self = [super init]) {
        NSLog(@"%@", dict);
        
        _responseDict = dict;
        _userName = dict[@"username"];
        _avatarUrl = dict[@"avatar_url"];
        _userId = dict[@"id"];
        _followersCount = [dict[@"followers_count"] integerValue];
        _followingsCount = [dict[@"followings_count"] integerValue];
        _tracksCount = [dict[@"track_count"] integerValue];
        _playlistsCount = [dict[@"playlist_count"] integerValue];
        
        
    }
    return self;
}

@end
