//
//  Collection.h
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Collection : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *monetizationModel;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, assign) double collectionIdentifier;
@property (nonatomic, assign) id releaseDay;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) double downloadCount;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, assign) BOOL downloadable;
@property (nonatomic, assign) id purchaseUrl;
@property (nonatomic, assign) double duration;
@property (nonatomic, strong) NSString *collectionDescription;
@property (nonatomic, assign) id purchaseTitle;
@property (nonatomic, strong) NSString *embeddableBy;
@property (nonatomic, strong) NSString *tagList;
@property (nonatomic, assign) id releaseMonth;
@property (nonatomic, strong) NSString *lastModified;
@property (nonatomic, assign) BOOL userFavorite;
@property (nonatomic, assign) id trackType;
@property (nonatomic, strong) NSString *streamUrl;
@property (nonatomic, strong) NSString *originalFormat;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) id bpm;
@property (nonatomic, strong) NSString *waveformUrl;
@property (nonatomic, assign) id labelName;
@property (nonatomic, strong) NSString *artworkUrl;
@property (nonatomic, assign) BOOL streamable;
@property (nonatomic, strong) NSString *attachmentsUri;
@property (nonatomic, assign) double commentCount;
@property (nonatomic, assign) BOOL commentable;
@property (nonatomic, assign) id keySignature;
@property (nonatomic, assign) id releases;
@property (nonatomic, assign) double playbackCount;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, assign) double userId;
@property (nonatomic, assign) id isrc;
@property (nonatomic, assign) double originalContentSize;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, assign) id videoUrl;
@property (nonatomic, assign) id releaseYear;
@property (nonatomic, assign) id labelId;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double userPlaybackCount;
@property (nonatomic, strong) NSString *permalinkUrl;
@property (nonatomic, strong) NSString *permalink;
@property (nonatomic, assign) double favoritingsCount;
@property (nonatomic, strong) NSString *sharing;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
