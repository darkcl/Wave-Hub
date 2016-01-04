//
//  WHPlaylistModel.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 4/1/16.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHPlaylistModel : NSObject

- (id)initWithTracks:(NSArray *)tracks nextHref:(NSString *)url;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSString *nextHref;

@end
