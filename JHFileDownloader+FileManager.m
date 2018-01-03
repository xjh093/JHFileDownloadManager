//
//  JHFileDownloader+FileManager.m
//  JHKit
//
//  Created by HaoCold on 2017/9/20.
//  Copyright © 2017年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
