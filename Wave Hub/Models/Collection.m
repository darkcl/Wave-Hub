//
//  Collection.m
//
//  Created by Yeung Yiu Hung on 18/10/2015
//  Copyright (c) 2015 Cherrypicks. All rights reserved.
//

#import "Collection.h"
#import "User.h"


NSString *const kCollectionPolicy = @"policy";
NSString *const kCollectionMonetizationModel = @"monetization_model";
NSString *const kCollectionCreatedAt = @"created_at";
NSString *const kCollectionId = @"id";
NSString *const kCollectionReleaseDay = @"release_day";
NSString *const kCollectionGenre = @"genre";
NSString *const kCollectionState = @"state";
NSString *const kCollectionDownloadCount = @"download_count";
NSString *const kCollectionLicense = @"license";
NSString *const kCollectionDownloadable = @"downloadable";
NSString *const kCollectionPurchaseUrl = @"purchase_url";
NSString *const kCollectionDuration = @"duration";
NSString *const kCollectionDescription = @"description";
NSString *const kCollectionPurchaseTitle = @"purchase_title";
NSString *const kCollectionEmbeddableBy = @"embeddable_by";
NSString *const kCollectionTagList = @"tag_list";
NSString *const kCollectionReleaseMonth = @"release_month";
NSString *const kCollectionLastModified = @"last_modified";
NSString *const kCollectionUserFavorite = @"user_favorite";
NSString *const kCollectionTrackType = @"track_type";
NSString *const kCollectionStreamUrl = @"stream_url";
NSString *const kCollectionOriginalFormat = @"original_format";
NSString *const kCollectionUser = @"user";
NSString *const kCollectionBpm = @"bpm";
NSString *const kCollectionWaveformUrl = @"waveform_url";
NSString *const kCollectionLabelName = @"label_name";
NSString *const kCollectionArtworkUrl = @"artwork_url";
NSString *const kCollectionStreamable = @"streamable";
NSString *const kCollectionAttachmentsUri = @"attachments_uri";
NSString *const kCollectionCommentCount = @"comment_count";
NSString *const kCollectionCommentable = @"commentable";
NSString *const kCollectionKeySignature = @"key_signature";
NSString *const kCollectionRelease = @"release";
NSString *const kCollectionPlaybackCount = @"playback_count";
NSString *const kCollectionKind = @"kind";
NSString *const kCollectionUserId = @"user_id";
NSString *const kCollectionIsrc = @"isrc";
NSString *const kCollectionOriginalContentSize = @"original_content_size";
NSString *const kCollectionDownloadUrl = @"download_url";
NSString *const kCollectionVideoUrl = @"video_url";
NSString *const kCollectionReleaseYear = @"release_year";
NSString *const kCollectionLabelId = @"label_id";
NSString *const kCollectionUri = @"uri";
NSString *const kCollectionTitle = @"title";
NSString *const kCollectionUserPlaybackCount = @"user_playback_count";
NSString *const kCollectionPermalinkUrl = @"permalink_url";
NSString *const kCollectionPermalink = @"permalink";
NSString *const kCollectionFavoritingsCount = @"favoritings_count";
NSString *const kCollectionSharing = @"sharing";


@interface Collection ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Collection

@synthesize policy = _policy;
@synthesize monetizationModel = _monetizationModel;
@synthesize createdAt = _createdAt;
@synthesize collectionIdentifier = _collectionIdentifier;
@synthesize releaseDay = _releaseDay;
@synthesize genre = _genre;
@synthesize state = _state;
@synthesize downloadCount = _downloadCount;
@synthesize license = _license;
@synthesize downloadable = _downloadable;
@synthesize purchaseUrl = _purchaseUrl;
@synthesize duration = _duration;
@synthesize collectionDescription = _collectionDescription;
@synthesize purchaseTitle = _purchaseTitle;
@synthesize embeddableBy = _embeddableBy;
@synthesize tagList = _tagList;
@synthesize releaseMonth = _releaseMonth;
@synthesize lastModified = _lastModified;
@synthesize userFavorite = _userFavorite;
@synthesize trackType = _trackType;
@synthesize streamUrl = _streamUrl;
@synthesize originalFormat = _originalFormat;
@synthesize user = _user;
@synthesize bpm = _bpm;
@synthesize waveformUrl = _waveformUrl;
@synthesize labelName = _labelName;
@synthesize artworkUrl = _artworkUrl;
@synthesize streamable = _streamable;
@synthesize attachmentsUri = _attachmentsUri;
@synthesize commentCount = _commentCount;
@synthesize commentable = _commentable;
@synthesize keySignature = _keySignature;
@synthesize releases = _releases;
@synthesize playbackCount = _playbackCount;
@synthesize kind = _kind;
@synthesize userId = _userId;
@synthesize isrc = _isrc;
@synthesize originalContentSize = _originalContentSize;
@synthesize downloadUrl = _downloadUrl;
@synthesize videoUrl = _videoUrl;
@synthesize releaseYear = _releaseYear;
@synthesize labelId = _labelId;
@synthesize uri = _uri;
@synthesize title = _title;
@synthesize userPlaybackCount = _userPlaybackCount;
@synthesize permalinkUrl = _permalinkUrl;
@synthesize permalink = _permalink;
@synthesize favoritingsCount = _favoritingsCount;
@synthesize sharing = _sharing;


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
            self.policy = [self objectOrNilForKey:kCollectionPolicy fromDictionary:dict];
            self.monetizationModel = [self objectOrNilForKey:kCollectionMonetizationModel fromDictionary:dict];
            self.createdAt = [self objectOrNilForKey:kCollectionCreatedAt fromDictionary:dict];
            self.collectionIdentifier = [[self objectOrNilForKey:kCollectionId fromDictionary:dict] doubleValue];
            self.releaseDay = [self objectOrNilForKey:kCollectionReleaseDay fromDictionary:dict];
            self.genre = [self objectOrNilForKey:kCollectionGenre fromDictionary:dict];
            self.state = [self objectOrNilForKey:kCollectionState fromDictionary:dict];
            self.downloadCount = [[self objectOrNilForKey:kCollectionDownloadCount fromDictionary:dict] doubleValue];
            self.license = [self objectOrNilForKey:kCollectionLicense fromDictionary:dict];
            self.downloadable = [[self objectOrNilForKey:kCollectionDownloadable fromDictionary:dict] boolValue];
            self.purchaseUrl = [self objectOrNilForKey:kCollectionPurchaseUrl fromDictionary:dict];
            self.duration = [[self objectOrNilForKey:kCollectionDuration fromDictionary:dict] doubleValue];
            self.collectionDescription = [self objectOrNilForKey:kCollectionDescription fromDictionary:dict];
            self.purchaseTitle = [self objectOrNilForKey:kCollectionPurchaseTitle fromDictionary:dict];
            self.embeddableBy = [self objectOrNilForKey:kCollectionEmbeddableBy fromDictionary:dict];
            self.tagList = [self objectOrNilForKey:kCollectionTagList fromDictionary:dict];
            self.releaseMonth = [self objectOrNilForKey:kCollectionReleaseMonth fromDictionary:dict];
            self.lastModified = [self objectOrNilForKey:kCollectionLastModified fromDictionary:dict];
            self.userFavorite = [[self objectOrNilForKey:kCollectionUserFavorite fromDictionary:dict] boolValue];
            self.trackType = [self objectOrNilForKey:kCollectionTrackType fromDictionary:dict];
            self.streamUrl = [self objectOrNilForKey:kCollectionStreamUrl fromDictionary:dict];
            self.originalFormat = [self objectOrNilForKey:kCollectionOriginalFormat fromDictionary:dict];
            self.user = [User modelObjectWithDictionary:[dict objectForKey:kCollectionUser]];
            self.bpm = [self objectOrNilForKey:kCollectionBpm fromDictionary:dict];
            self.waveformUrl = [self objectOrNilForKey:kCollectionWaveformUrl fromDictionary:dict];
            self.labelName = [self objectOrNilForKey:kCollectionLabelName fromDictionary:dict];
            self.artworkUrl = [self objectOrNilForKey:kCollectionArtworkUrl fromDictionary:dict];
            self.streamable = [[self objectOrNilForKey:kCollectionStreamable fromDictionary:dict] boolValue];
            self.attachmentsUri = [self objectOrNilForKey:kCollectionAttachmentsUri fromDictionary:dict];
            self.commentCount = [[self objectOrNilForKey:kCollectionCommentCount fromDictionary:dict] doubleValue];
            self.commentable = [[self objectOrNilForKey:kCollectionCommentable fromDictionary:dict] boolValue];
            self.keySignature = [self objectOrNilForKey:kCollectionKeySignature fromDictionary:dict];
            self.releases = [self objectOrNilForKey:kCollectionRelease fromDictionary:dict];
            self.playbackCount = [[self objectOrNilForKey:kCollectionPlaybackCount fromDictionary:dict] doubleValue];
            self.kind = [self objectOrNilForKey:kCollectionKind fromDictionary:dict];
            self.userId = [[self objectOrNilForKey:kCollectionUserId fromDictionary:dict] doubleValue];
            self.isrc = [self objectOrNilForKey:kCollectionIsrc fromDictionary:dict];
            self.originalContentSize = [[self objectOrNilForKey:kCollectionOriginalContentSize fromDictionary:dict] doubleValue];
            self.downloadUrl = [self objectOrNilForKey:kCollectionDownloadUrl fromDictionary:dict];
            self.videoUrl = [self objectOrNilForKey:kCollectionVideoUrl fromDictionary:dict];
            self.releaseYear = [self objectOrNilForKey:kCollectionReleaseYear fromDictionary:dict];
            self.labelId = [self objectOrNilForKey:kCollectionLabelId fromDictionary:dict];
            self.uri = [self objectOrNilForKey:kCollectionUri fromDictionary:dict];
            self.title = [self objectOrNilForKey:kCollectionTitle fromDictionary:dict];
            self.userPlaybackCount = [[self objectOrNilForKey:kCollectionUserPlaybackCount fromDictionary:dict] doubleValue];
            self.permalinkUrl = [self objectOrNilForKey:kCollectionPermalinkUrl fromDictionary:dict];
            self.permalink = [self objectOrNilForKey:kCollectionPermalink fromDictionary:dict];
            self.favoritingsCount = [[self objectOrNilForKey:kCollectionFavoritingsCount fromDictionary:dict] doubleValue];
            self.sharing = [self objectOrNilForKey:kCollectionSharing fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.policy forKey:kCollectionPolicy];
    [mutableDict setValue:self.monetizationModel forKey:kCollectionMonetizationModel];
    [mutableDict setValue:self.createdAt forKey:kCollectionCreatedAt];
    [mutableDict setValue:[NSNumber numberWithDouble:self.collectionIdentifier] forKey:kCollectionId];
    [mutableDict setValue:self.releaseDay forKey:kCollectionReleaseDay];
    [mutableDict setValue:self.genre forKey:kCollectionGenre];
    [mutableDict setValue:self.state forKey:kCollectionState];
    [mutableDict setValue:[NSNumber numberWithDouble:self.downloadCount] forKey:kCollectionDownloadCount];
    [mutableDict setValue:self.license forKey:kCollectionLicense];
    [mutableDict setValue:[NSNumber numberWithBool:self.downloadable] forKey:kCollectionDownloadable];
    [mutableDict setValue:self.purchaseUrl forKey:kCollectionPurchaseUrl];
    [mutableDict setValue:[NSNumber numberWithDouble:self.duration] forKey:kCollectionDuration];
    [mutableDict setValue:self.collectionDescription forKey:kCollectionDescription];
    [mutableDict setValue:self.purchaseTitle forKey:kCollectionPurchaseTitle];
    [mutableDict setValue:self.embeddableBy forKey:kCollectionEmbeddableBy];
    [mutableDict setValue:self.tagList forKey:kCollectionTagList];
    [mutableDict setValue:self.releaseMonth forKey:kCollectionReleaseMonth];
    [mutableDict setValue:self.lastModified forKey:kCollectionLastModified];
    [mutableDict setValue:[NSNumber numberWithBool:self.userFavorite] forKey:kCollectionUserFavorite];
    [mutableDict setValue:self.trackType forKey:kCollectionTrackType];
    [mutableDict setValue:self.streamUrl forKey:kCollectionStreamUrl];
    [mutableDict setValue:self.originalFormat forKey:kCollectionOriginalFormat];
    [mutableDict setValue:[self.user dictionaryRepresentation] forKey:kCollectionUser];
    [mutableDict setValue:self.bpm forKey:kCollectionBpm];
    [mutableDict setValue:self.waveformUrl forKey:kCollectionWaveformUrl];
    [mutableDict setValue:self.labelName forKey:kCollectionLabelName];
    [mutableDict setValue:self.artworkUrl forKey:kCollectionArtworkUrl];
    [mutableDict setValue:[NSNumber numberWithBool:self.streamable] forKey:kCollectionStreamable];
    [mutableDict setValue:self.attachmentsUri forKey:kCollectionAttachmentsUri];
    [mutableDict setValue:[NSNumber numberWithDouble:self.commentCount] forKey:kCollectionCommentCount];
    [mutableDict setValue:[NSNumber numberWithBool:self.commentable] forKey:kCollectionCommentable];
    [mutableDict setValue:self.keySignature forKey:kCollectionKeySignature];
    [mutableDict setValue:self.releases forKey:kCollectionRelease];
    [mutableDict setValue:[NSNumber numberWithDouble:self.playbackCount] forKey:kCollectionPlaybackCount];
    [mutableDict setValue:self.kind forKey:kCollectionKind];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userId] forKey:kCollectionUserId];
    [mutableDict setValue:self.isrc forKey:kCollectionIsrc];
    [mutableDict setValue:[NSNumber numberWithDouble:self.originalContentSize] forKey:kCollectionOriginalContentSize];
    [mutableDict setValue:self.downloadUrl forKey:kCollectionDownloadUrl];
    [mutableDict setValue:self.videoUrl forKey:kCollectionVideoUrl];
    [mutableDict setValue:self.releaseYear forKey:kCollectionReleaseYear];
    [mutableDict setValue:self.labelId forKey:kCollectionLabelId];
    [mutableDict setValue:self.uri forKey:kCollectionUri];
    [mutableDict setValue:self.title forKey:kCollectionTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.userPlaybackCount] forKey:kCollectionUserPlaybackCount];
    [mutableDict setValue:self.permalinkUrl forKey:kCollectionPermalinkUrl];
    [mutableDict setValue:self.permalink forKey:kCollectionPermalink];
    [mutableDict setValue:[NSNumber numberWithDouble:self.favoritingsCount] forKey:kCollectionFavoritingsCount];
    [mutableDict setValue:self.sharing forKey:kCollectionSharing];

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

    self.policy = [aDecoder decodeObjectForKey:kCollectionPolicy];
    self.monetizationModel = [aDecoder decodeObjectForKey:kCollectionMonetizationModel];
    self.createdAt = [aDecoder decodeObjectForKey:kCollectionCreatedAt];
    self.collectionIdentifier = [aDecoder decodeDoubleForKey:kCollectionId];
    self.releaseDay = [aDecoder decodeObjectForKey:kCollectionReleaseDay];
    self.genre = [aDecoder decodeObjectForKey:kCollectionGenre];
    self.state = [aDecoder decodeObjectForKey:kCollectionState];
    self.downloadCount = [aDecoder decodeDoubleForKey:kCollectionDownloadCount];
    self.license = [aDecoder decodeObjectForKey:kCollectionLicense];
    self.downloadable = [aDecoder decodeBoolForKey:kCollectionDownloadable];
    self.purchaseUrl = [aDecoder decodeObjectForKey:kCollectionPurchaseUrl];
    self.duration = [aDecoder decodeDoubleForKey:kCollectionDuration];
    self.collectionDescription = [aDecoder decodeObjectForKey:kCollectionDescription];
    self.purchaseTitle = [aDecoder decodeObjectForKey:kCollectionPurchaseTitle];
    self.embeddableBy = [aDecoder decodeObjectForKey:kCollectionEmbeddableBy];
    self.tagList = [aDecoder decodeObjectForKey:kCollectionTagList];
    self.releaseMonth = [aDecoder decodeObjectForKey:kCollectionReleaseMonth];
    self.lastModified = [aDecoder decodeObjectForKey:kCollectionLastModified];
    self.userFavorite = [aDecoder decodeBoolForKey:kCollectionUserFavorite];
    self.trackType = [aDecoder decodeObjectForKey:kCollectionTrackType];
    self.streamUrl = [aDecoder decodeObjectForKey:kCollectionStreamUrl];
    self.originalFormat = [aDecoder decodeObjectForKey:kCollectionOriginalFormat];
    self.user = [aDecoder decodeObjectForKey:kCollectionUser];
    self.bpm = [aDecoder decodeObjectForKey:kCollectionBpm];
    self.waveformUrl = [aDecoder decodeObjectForKey:kCollectionWaveformUrl];
    self.labelName = [aDecoder decodeObjectForKey:kCollectionLabelName];
    self.artworkUrl = [aDecoder decodeObjectForKey:kCollectionArtworkUrl];
    self.streamable = [aDecoder decodeBoolForKey:kCollectionStreamable];
    self.attachmentsUri = [aDecoder decodeObjectForKey:kCollectionAttachmentsUri];
    self.commentCount = [aDecoder decodeDoubleForKey:kCollectionCommentCount];
    self.commentable = [aDecoder decodeBoolForKey:kCollectionCommentable];
    self.keySignature = [aDecoder decodeObjectForKey:kCollectionKeySignature];
    self.releases = [aDecoder decodeObjectForKey:kCollectionRelease];
    self.playbackCount = [aDecoder decodeDoubleForKey:kCollectionPlaybackCount];
    self.kind = [aDecoder decodeObjectForKey:kCollectionKind];
    self.userId = [aDecoder decodeDoubleForKey:kCollectionUserId];
    self.isrc = [aDecoder decodeObjectForKey:kCollectionIsrc];
    self.originalContentSize = [aDecoder decodeDoubleForKey:kCollectionOriginalContentSize];
    self.downloadUrl = [aDecoder decodeObjectForKey:kCollectionDownloadUrl];
    self.videoUrl = [aDecoder decodeObjectForKey:kCollectionVideoUrl];
    self.releaseYear = [aDecoder decodeObjectForKey:kCollectionReleaseYear];
    self.labelId = [aDecoder decodeObjectForKey:kCollectionLabelId];
    self.uri = [aDecoder decodeObjectForKey:kCollectionUri];
    self.title = [aDecoder decodeObjectForKey:kCollectionTitle];
    self.userPlaybackCount = [aDecoder decodeDoubleForKey:kCollectionUserPlaybackCount];
    self.permalinkUrl = [aDecoder decodeObjectForKey:kCollectionPermalinkUrl];
    self.permalink = [aDecoder decodeObjectForKey:kCollectionPermalink];
    self.favoritingsCount = [aDecoder decodeDoubleForKey:kCollectionFavoritingsCount];
    self.sharing = [aDecoder decodeObjectForKey:kCollectionSharing];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_policy forKey:kCollectionPolicy];
    [aCoder encodeObject:_monetizationModel forKey:kCollectionMonetizationModel];
    [aCoder encodeObject:_createdAt forKey:kCollectionCreatedAt];
    [aCoder encodeDouble:_collectionIdentifier forKey:kCollectionId];
    [aCoder encodeObject:_releaseDay forKey:kCollectionReleaseDay];
    [aCoder encodeObject:_genre forKey:kCollectionGenre];
    [aCoder encodeObject:_state forKey:kCollectionState];
    [aCoder encodeDouble:_downloadCount forKey:kCollectionDownloadCount];
    [aCoder encodeObject:_license forKey:kCollectionLicense];
    [aCoder encodeBool:_downloadable forKey:kCollectionDownloadable];
    [aCoder encodeObject:_purchaseUrl forKey:kCollectionPurchaseUrl];
    [aCoder encodeDouble:_duration forKey:kCollectionDuration];
    [aCoder encodeObject:_collectionDescription forKey:kCollectionDescription];
    [aCoder encodeObject:_purchaseTitle forKey:kCollectionPurchaseTitle];
    [aCoder encodeObject:_embeddableBy forKey:kCollectionEmbeddableBy];
    [aCoder encodeObject:_tagList forKey:kCollectionTagList];
    [aCoder encodeObject:_releaseMonth forKey:kCollectionReleaseMonth];
    [aCoder encodeObject:_lastModified forKey:kCollectionLastModified];
    [aCoder encodeBool:_userFavorite forKey:kCollectionUserFavorite];
    [aCoder encodeObject:_trackType forKey:kCollectionTrackType];
    [aCoder encodeObject:_streamUrl forKey:kCollectionStreamUrl];
    [aCoder encodeObject:_originalFormat forKey:kCollectionOriginalFormat];
    [aCoder encodeObject:_user forKey:kCollectionUser];
    [aCoder encodeObject:_bpm forKey:kCollectionBpm];
    [aCoder encodeObject:_waveformUrl forKey:kCollectionWaveformUrl];
    [aCoder encodeObject:_labelName forKey:kCollectionLabelName];
    [aCoder encodeObject:_artworkUrl forKey:kCollectionArtworkUrl];
    [aCoder encodeBool:_streamable forKey:kCollectionStreamable];
    [aCoder encodeObject:_attachmentsUri forKey:kCollectionAttachmentsUri];
    [aCoder encodeDouble:_commentCount forKey:kCollectionCommentCount];
    [aCoder encodeBool:_commentable forKey:kCollectionCommentable];
    [aCoder encodeObject:_keySignature forKey:kCollectionKeySignature];
    [aCoder encodeObject:_releases forKey:kCollectionRelease];
    [aCoder encodeDouble:_playbackCount forKey:kCollectionPlaybackCount];
    [aCoder encodeObject:_kind forKey:kCollectionKind];
    [aCoder encodeDouble:_userId forKey:kCollectionUserId];
    [aCoder encodeObject:_isrc forKey:kCollectionIsrc];
    [aCoder encodeDouble:_originalContentSize forKey:kCollectionOriginalContentSize];
    [aCoder encodeObject:_downloadUrl forKey:kCollectionDownloadUrl];
    [aCoder encodeObject:_videoUrl forKey:kCollectionVideoUrl];
    [aCoder encodeObject:_releaseYear forKey:kCollectionReleaseYear];
    [aCoder encodeObject:_labelId forKey:kCollectionLabelId];
    [aCoder encodeObject:_uri forKey:kCollectionUri];
    [aCoder encodeObject:_title forKey:kCollectionTitle];
    [aCoder encodeDouble:_userPlaybackCount forKey:kCollectionUserPlaybackCount];
    [aCoder encodeObject:_permalinkUrl forKey:kCollectionPermalinkUrl];
    [aCoder encodeObject:_permalink forKey:kCollectionPermalink];
    [aCoder encodeDouble:_favoritingsCount forKey:kCollectionFavoritingsCount];
    [aCoder encodeObject:_sharing forKey:kCollectionSharing];
}

- (id)copyWithZone:(NSZone *)zone
{
    Collection *copy = [[Collection alloc] init];
    
    if (copy) {

        copy.policy = [self.policy copyWithZone:zone];
        copy.monetizationModel = [self.monetizationModel copyWithZone:zone];
        copy.createdAt = [self.createdAt copyWithZone:zone];
        copy.collectionIdentifier = self.collectionIdentifier;
        copy.releaseDay = [self.releaseDay copyWithZone:zone];
        copy.genre = [self.genre copyWithZone:zone];
        copy.state = [self.state copyWithZone:zone];
        copy.downloadCount = self.downloadCount;
        copy.license = [self.license copyWithZone:zone];
        copy.downloadable = self.downloadable;
        copy.purchaseUrl = [self.purchaseUrl copyWithZone:zone];
        copy.duration = self.duration;
        copy.collectionDescription = [self.collectionDescription copyWithZone:zone];
        copy.purchaseTitle = [self.purchaseTitle copyWithZone:zone];
        copy.embeddableBy = [self.embeddableBy copyWithZone:zone];
        copy.tagList = [self.tagList copyWithZone:zone];
        copy.releaseMonth = [self.releaseMonth copyWithZone:zone];
        copy.lastModified = [self.lastModified copyWithZone:zone];
        copy.userFavorite = self.userFavorite;
        copy.trackType = [self.trackType copyWithZone:zone];
        copy.streamUrl = [self.streamUrl copyWithZone:zone];
        copy.originalFormat = [self.originalFormat copyWithZone:zone];
        copy.user = [self.user copyWithZone:zone];
        copy.bpm = [self.bpm copyWithZone:zone];
        copy.waveformUrl = [self.waveformUrl copyWithZone:zone];
        copy.labelName = [self.labelName copyWithZone:zone];
        copy.artworkUrl = [self.artworkUrl copyWithZone:zone];
        copy.streamable = self.streamable;
        copy.attachmentsUri = [self.attachmentsUri copyWithZone:zone];
        copy.commentCount = self.commentCount;
        copy.commentable = self.commentable;
        copy.keySignature = [self.keySignature copyWithZone:zone];
        copy.releases = [self.releases copyWithZone:zone];
        copy.playbackCount = self.playbackCount;
        copy.kind = [self.kind copyWithZone:zone];
        copy.userId = self.userId;
        copy.isrc = [self.isrc copyWithZone:zone];
        copy.originalContentSize = self.originalContentSize;
        copy.downloadUrl = [self.downloadUrl copyWithZone:zone];
        copy.videoUrl = [self.videoUrl copyWithZone:zone];
        copy.releaseYear = [self.releaseYear copyWithZone:zone];
        copy.labelId = [self.labelId copyWithZone:zone];
        copy.uri = [self.uri copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.userPlaybackCount = self.userPlaybackCount;
        copy.permalinkUrl = [self.permalinkUrl copyWithZone:zone];
        copy.permalink = [self.permalink copyWithZone:zone];
        copy.favoritingsCount = self.favoritingsCount;
        copy.sharing = [self.sharing copyWithZone:zone];
    }
    
    return copy;
}


@end
