//
//  WHPlaylistModel.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 4/1/16.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "WHPlaylistModel.h"

@implementation WHPlaylistModel

- (id)initWithTracks:(NSArray *)tracks nextHref:(NSString *)url{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        _responseDict = dict;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    if ((self = [super init])) {
        _responseDict = [decoder decodeObjectForKey:@"responseDict"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_responseDict forKey:@"responseDict"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", self.responseDict];
}

- (BOOL)isEqual:(id)object{
    WHPlaylistModel *otherTrack = (WHPlaylistModel *)object;
    return [_responseDict isEqual:otherTrack.responseDict];
}

- (NSString *)coverImageUrl{
    if ([self.responseDict[@"artwork_url"] isKindOfClass:[NSString class]]) {
        return self.responseDict[@"artwork_url"];
    }else{
        return nil;
    }
}

- (NSString *)playlistTitle{
    if ([self.responseDict[@"title"] isKindOfClass:[NSString class]]) {
        return self.responseDict[@"title"];
    }else{
        return nil;
    }
}

- (NSString *)playlistId{
    if ([self.responseDict[@"id"] isKindOfClass:[NSString class]]) {
        return self.responseDict[@"id"];
    }else{
        return nil;
    }
}

- (NSArray <WHTrackModel *> *)playlistTracks{
    if ([self.responseDict[@"tracks"] isKindOfClass:[NSArray class]]) {
        NSArray *tracksArray = self.responseDict[@"tracks"];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDict in tracksArray) {
            [result addObject:[[WHTrackModel alloc] initWithInfo:infoDict]];
        }
        
        return result;
    }else{
        return nil;
    }
}

@end
