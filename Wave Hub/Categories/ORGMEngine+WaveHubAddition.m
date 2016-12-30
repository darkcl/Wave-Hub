//
//  ORGMEngine+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 30/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "ORGMEngine+WaveHubAddition.h"

@implementation ORGMEngine (WaveHubAddition)

static ORGMEngine *sharedMyManager = nil;

+ (instancetype)sharedInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

@end
