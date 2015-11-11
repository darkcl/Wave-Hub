//
//  User.m
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import "User.h"


NSString *const kUserId = @"id";
NSString *const kUserLastModified = @"last_modified";
NSString *const kUserUsername = @"username";
NSString *const kUserPermalinkUrl = @"permalink_url";
NSString *const kUserKind = @"kind";
NSString *const kUserPermalink = @"permalink";
NSString *const kUserUri = @"uri";
NSString *const kUserAvatarUrl = @"avatar_url";


@interface User ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation User

@synthesize userIdentifier = _userIdentifier;
@synthesize lastModified = _lastModified;
@synthesize username = _username;
@synthesize permalinkUrl = _permalinkUrl;
@synthesize kind = _kind;
@synthesize permalink = _permalink;
@synthesize uri = _uri;
@synthesize avatarUrl = _avatarUrl;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.userIdentifier = [[self objectOrNilForKey:kUserId fromDictionary:dict] doubleValue];
            self.lastModified = [self objectOrNilForKey:kUserLastModified fromDictionary:dict];
            self.username = [self objectOrNilForKey:kUserUsername fromDictionary:dict];
            self.permalinkUrl = [self objectOrNilForKey:kUserPermalinkUrl fromDictionary:dict];
            self.kind = [self objectOrNilForKey:kUserKind fromDictionary:dict];
            self.permalink = [self objectOrNilForKey:kUserPermalink fromDictionary:dict];
            self.uri = [self objectOrNilForKey:kUserUri fromDictionary:dict];
            self.avatarUrl = [self objectOrNilForKey:kUserAvatarUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userIdentifier] forKey:kUserId];
    [mutableDict setValue:self.lastModified forKey:kUserLastModified];
    [mutableDict setValue:self.username forKey:kUserUsername];
    [mutableDict setValue:self.permalinkUrl forKey:kUserPermalinkUrl];
    [mutableDict setValue:self.kind forKey:kUserKind];
    [mutableDict setValue:self.permalink forKey:kUserPermalink];
    [mutableDict setValue:self.uri forKey:kUserUri];
    [mutableDict setValue:self.avatarUrl forKey:kUserAvatarUrl];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.userIdentifier = [aDecoder decodeDoubleForKey:kUserId];
    self.lastModified = [aDecoder decodeObjectForKey:kUserLastModified];
    self.username = [aDecoder decodeObjectForKey:kUserUsername];
    self.permalinkUrl = [aDecoder decodeObjectForKey:kUserPermalinkUrl];
    self.kind = [aDecoder decodeObjectForKey:kUserKind];
    self.permalink = [aDecoder decodeObjectForKey:kUserPermalink];
    self.uri = [aDecoder decodeObjectForKey:kUserUri];
    self.avatarUrl = [aDecoder decodeObjectForKey:kUserAvatarUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_userIdentifier forKey:kUserId];
    [aCoder encodeObject:_lastModified forKey:kUserLastModified];
    [aCoder encodeObject:_username forKey:kUserUsername];
    [aCoder encodeObject:_permalinkUrl forKey:kUserPermalinkUrl];
    [aCoder encodeObject:_kind forKey:kUserKind];
    [aCoder encodeObject:_permalink forKey:kUserPermalink];
    [aCoder encodeObject:_uri forKey:kUserUri];
    [aCoder encodeObject:_avatarUrl forKey:kUserAvatarUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    User *copy = [[User alloc] init];
    
    if (copy) {

        copy.userIdentifier = self.userIdentifier;
        copy.lastModified = [self.lastModified copyWithZone:zone];
        copy.username = [self.username copyWithZone:zone];
        copy.permalinkUrl = [self.permalinkUrl copyWithZone:zone];
        copy.kind = [self.kind copyWithZone:zone];
        copy.permalink = [self.permalink copyWithZone:zone];
        copy.uri = [self.uri copyWithZone:zone];
        copy.avatarUrl = [self.avatarUrl copyWithZone:zone];
    }
    
    return copy;
}


@end
