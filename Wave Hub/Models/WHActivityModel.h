//
//  WHActivityModel.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 25/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Type	Origin
 track	Track
 track-sharing	Track and Sharing-Note
 comment	Comment with Mini-User and Mini-Track
 favoriting	Mini-Track and Mini-User
 */


typedef NS_ENUM(NSInteger, WHActivityType) {
    WHActivityTypeTrack,
    WHActivityTypeTrackRepost,
    
};

@interface WHActivityModel : NSObject {
    NSDictionary *infoDict;
}

- (id)initWithDictionary:(NSDictionary *)dict;



@end
