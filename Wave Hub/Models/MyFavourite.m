//
//  MyFavourite.m
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import "MyFavourite.h"
#import "Collection.h"


NSString *const kMyFavouriteNextHref = @"next_href";
NSString *const kMyFavouriteCollection = @"collection";


@interface MyFavourite ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation MyFavourite

@synthesize nextHref = _nextHref;
@synthesize collection = _collection;


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
            self.nextHref = [self objectOrNilForKey:kMyFavouriteNextHref fromDictionary:dict];
    NSObject *receivedCollection = [dict objectForKey:kMyFavouriteCollection];
    NSMutableArray *parsedCollection = [NSMutableArray array];
    if ([receivedCollection isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedCollection) {
            if ([item isKindOfClass:[NSDictionary class]] && item[@"stream_url"] != nil) {
                [parsedCollection addObject:[Collection modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedCollection isKindOfClass:[NSDictionary class]]) {
       [parsedCollection addObject:[Collection modelObjectWithDictionary:(NSDictionary *)receivedCollection]];
    }

    self.collection = [NSArray arrayWithArray:parsedCollection];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.nextHref forKey:kMyFavouriteNextHref];
    NSMutableArray *tempArrayForCollection = [NSMutableArray array];
    for (NSObject *subArrayObject in self.collection) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCollection addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCollection addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCollection] forKey:kMyFavouriteCollection];

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

    self.nextHref = [aDecoder decodeObjectForKey:kMyFavouriteNextHref];
    self.collection = [aDecoder decodeObjectForKey:kMyFavouriteCollection];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_nextHref forKey:kMyFavouriteNextHref];
    [aCoder encodeObject:_collection forKey:kMyFavouriteCollection];
}

- (id)copyWithZone:(NSZone *)zone
{
    MyFavourite *copy = [[MyFavourite alloc] init];
    
    if (copy) {

        copy.nextHref = [self.nextHref copyWithZone:zone];
        copy.collection = [self.collection copyWithZone:zone];
    }
    
    return copy;
}


@end
