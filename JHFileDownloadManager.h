//
//  JHFileDownloadManager.h
//  JHKit
//
//  Created by HaoCold on 2017/9/22.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHFileDownloader.h"

@interface JHFileDownloadManager : NSObject

+ (instancetype)manager;

- (JHFileDownloader *)jh_downFileWith:(NSURL *)url;

- (void)jh_downFileWith:(NSURL *)url
               progress:(JHFileDownloadingProgress)progress
                success:(JHFileDownloadSuccess)success
                 failer:(JHFileDownloadFailer)failer;

- (void)jh_pause:(NSURL *)url;

- (void)jh_resume:(NSURL *)url;

- (void)jh_cancel:(NSURL *)url;

- (void)jh_pauseAll;

- (void)jh_cancelAll;

@end
