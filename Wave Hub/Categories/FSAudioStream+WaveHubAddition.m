//
//  FSAudioStream+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 21/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "FSAudioStream+WaveHubAddition.h"

@implementation FSAudioStream (WaveHubAddition)

static FSAudioStream *sharedMyManager = nil;

+ (instancetype)sharedInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

@end
