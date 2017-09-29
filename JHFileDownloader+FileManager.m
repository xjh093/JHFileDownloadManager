//
//  JHFileDownloader+FileManager.m
//  JHKit
//
//  Created by HaoCold on 2017/9/20.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import "JHFileDownloader+FileManager.h"

@implementation JHFileDownloader (FileManager)
/// file exist or not
- (BOOL)jh_isFileExist:(NSString *)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/// file size
- (long long)jh_fileSize:(NSString *)path{
    if (![self jh_isFileExist:path]) {
        return 0;
    }
    
    NSDictionary *infoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [infoDic[NSFileSize] longLongValue];
}

/// move file
- (void)jh_moveFile:(NSString *)fromPath to:(NSString *)toPath{
    if (![self jh_isFileExist:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

/// remove file
- (void)jh_removeFile:(NSString *)path{
    if (![self jh_isFileExist:path]) {
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
@end
