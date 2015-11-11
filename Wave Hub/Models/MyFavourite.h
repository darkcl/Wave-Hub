//
//  MyFavourite.h
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MyFavourite : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *nextHref;
@property (nonatomic, strong) NSArray *collection;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
