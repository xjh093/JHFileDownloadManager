//
//  JHFileDownloader.h
//  JHKit
//
//  Created by HaoCold on 2017/9/19.
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JHFileDownloadState) {
    JHFileDownloadStateUnknown,
    JHFileDownloadStateDowning,
    JHFileDownloadStatePause,
    JHFileDownloadStateSuccess,
    JHFileDownloadStateFailer
};

typedef void(^JHFileDownloadingSize)(long long size);
typedef void(^JHFileDownloadSuccess)(NSString *path);
typedef void(^JHFileDownloadFailer)(NSError *error);
typedef void(^JHFileDownloadStateChange)(JHFileDownloadState state);
typedef void(^JHFileDownloadingProgress)(float progress);

@interface JHFileDownloader : NSObject

/// file total size
@property (assign,  nonatomic,  readonly) long long size;
/// download state
@property (assign,  nonatomic) JHFileDownloadState  state;
/// downloading file size
@property (copy,    nonatomic) JHFileDownloadingSize downloadingSize;
/// download file success
@property (copy,    nonatomic) JHFileDownloadSuccess downloadSuccess;
/// download file failer
@property (copy,    nonatomic) JHFileDownloadFailer  downloadFailer;
/// download state changed
@property (copy,    nonatomic) JHFileDownloadStateChange downloadStateChange;
/// downloading progress
@property (copy,    nonatomic) JHFileDownloadingProgress downloadingProgress;

/// based on the url to download filese
- (void)jh_downFileWith:(NSURL *)url;

///
- (void)jh_downFileWith:(NSURL *)url
               progress:(JHFileDownloadingProgress)progress
                success:(JHFileDownloadSuccess)success
                 failer:(JHFileDownloadFailer)failer;

/// pause download task
- (void)jh_pause;

/// resume download task
- (void)jh_resume;

/// cancel download task, will remove temp file
- (void)jh_cancel;

@end
