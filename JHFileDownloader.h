//
//  JHFileDownloader.h
//  JHKit
//
//  Created by HaoCold on 2017/9/19.
//  Copyright © 2017年 HaoCold. All rights reserved.
// 

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
