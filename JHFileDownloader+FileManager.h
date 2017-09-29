//
//  JHFileDownloader+FileManager.h
//  JHKit
//
//  Created by HaoCold on 2017/9/20.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import "JHFileDownloader.h"

@interface JHFileDownloader (FileManager)
/// file exist or not
- (BOOL)jh_isFileExist:(NSString *)path;

/// file size
- (long long)jh_fileSize:(NSString *)path;

/// move file
- (void)jh_moveFile:(NSString *)fromPath to:(NSString *)toPath;

/// remove file
- (void)jh_removeFile:(NSString *)path;

@end
