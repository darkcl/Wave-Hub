//
//  MusicTableViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 14/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "MusicTableViewCell.h"
#import <DLImageLoader/DLImageLoader.h>

@implementation MusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)startLoadingCover:(NSString *)url{
//    _coverImageView.alpha = 0.0;
    
    if (url != nil && ![url isKindOfClass:[NSNull class]]) {
        tempUrl = url;
        [[DLImageLoader sharedInstance] imageFromUrl:url
                                           completed:^(NSError *error, UIImage *image) {
                                               if (!error) {
                                                   self.coverImageView.image = image;
                                               }
                                           }];
    }
}

- (void)cancelLoadingCover{
    if (!tempUrl) {
        [[DLImageLoader sharedInstance] cancelOperation:tempUrl];
    }
}

@end
