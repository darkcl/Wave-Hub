//
//  NSData+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "NSData+WaveHubAddition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (WaveHubAddition)

- (NSString*)md5String
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( self.bytes, (int)self.length, result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (NSString *)utf8String{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc] initWithData:self encoding:enc];
}

@end
