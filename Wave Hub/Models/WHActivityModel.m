//
//  WHActivityModel.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 25/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "WHActivityModel.h"

@implementation WHActivityModel

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        infoDict = dict;
    }
    return self;
}

@end
