//
//  NSString+JHFileDownloader.m
//  JHKit
//
//  Created by HaoCold on 2017/9/20.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import "NSString+JHFileDownloader.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (JHFileDownloader)
- (NSString *)jh_md5String{
    const char *data = self.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    NSMutableString *outString = @"".mutableCopy;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [outString appendFormat:@"%02x",digest[i]];
    }
    return outString;
}
@end
