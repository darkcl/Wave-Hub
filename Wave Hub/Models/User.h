//
//  User.h
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface User : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double userIdentifier;
@property (nonatomic, strong) NSString *lastModified;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *permalinkUrl;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *permalink;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *avatarUrl;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
