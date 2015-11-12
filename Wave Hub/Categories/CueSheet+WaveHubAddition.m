//
//  CueSheet+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "CueSheet+WaveHubAddition.h"

NSString const *kCueSheetUrlKey = @"com.memoryleadks.cuesheet.cueurl";

@implementation CueSheet (WaveHubAddition)

- (void)setCueUrl:(NSURL *)cueUrl
{
    objc_setAssociatedObject(self, &kCueSheetUrlKey, cueUrl, OBJC_ASSOCIATION_COPY);
}

- (NSURL *)cueUrl
{
    return objc_getAssociatedObject(self, &kCueSheetUrlKey);
}

@end
