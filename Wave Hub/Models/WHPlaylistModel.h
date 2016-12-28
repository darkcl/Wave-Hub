//
//  WHPlaylistModel.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 4/1/16.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHPlaylistModel : NSObject <NSCoding> {
    
}

- (id)initWithTracks:(NSArray *)tracks nextHref:(NSString *)url;

// SoundCloud Only
- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSString *nextHref;


@property (nonatomic, strong) NSDictionary *responseDict;

@property (nonatomic, strong, readonly) NSString *coverImageUrl;
@property (nonatomic, strong, readonly) NSString *playlistTitle;
@property (nonatomic, strong, readonly) NSString *playlistId;

@property (nonatomic, strong, readonly) NSArray <WHTrackModel *> *playlistTracks;

@end
