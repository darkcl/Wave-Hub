//
//  WHTrackModel.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WHTrackType) {
    WHTrackTypeLocal,
    WHTrackTypeSoundCloud
};

@interface WHTrackModel : NSObject <NSCoding>

@property (nonatomic, strong) NSURL *trackUrl;
@property WHTrackType trackType;
@property (nonatomic, strong) NSString *md5hash;

@property (nonatomic, strong) NSString *trackTitle;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *albumCoverUrl;

@property (nonatomic, strong) UIImage *albumCoverImage;
@property float duration;

@property (nonatomic, strong) NSDictionary *responseDict;

- (id)initWithInfo:(NSDictionary *)dict;

@end
