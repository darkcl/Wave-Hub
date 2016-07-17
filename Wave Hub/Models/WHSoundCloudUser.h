//
//  WHSoundCloudUser.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 user =     {
 "avatar_url" = "https://i1.sndcdn.com/avatars-000033573533-funbps-large.jpg";
 id = 27639974;
 kind = user;
 "last_modified" = "2014/11/10 18:27:16 +0000";
 permalink = "the-magic-chord";
 "permalink_url" = "http://soundcloud.com/the-magic-chord";
 uri = "https://api.soundcloud.com/users/27639974";
 username = "The Magic Chord";
 };
 */
@interface WHSoundCloudUser : NSObject

- (id)initWithUserInfo:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatarUrl;
@property NSInteger followingsCount;
@property NSInteger followersCount;
@property NSInteger tracksCount;
@property NSInteger playlistsCount;

@property (nonatomic, strong) NSDictionary *responseDict;

@end
