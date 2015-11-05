//
//  WHWebrequestManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHWebrequestManager.h"

@interface WHWebrequestManager ()
@property (nonatomic, strong) SoundCloudPort *soundCloudPort;
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
        self.soundCloudPort = [[SoundCloudPort alloc] initWithClientId:@"47724625bbc02bbc335e84f2ed87c001"
                                                          clientSecret:@"8614d82e8d7e8f90c91ec144aec29986"];
    }
    return self;
}

@end
