//
//  WHWebrequestManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHWebrequestManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) SoundCloudPort *soundCloudPort;

@end
