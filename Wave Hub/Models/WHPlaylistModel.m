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


@end
