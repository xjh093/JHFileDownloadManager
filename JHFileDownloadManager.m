//
//  JHFileDownloadManager.m
//  JHKit
//
//  Created by HaoCold on 2017/9/22.
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

#import "JHFileDownloadManager.h"
#import "NSString+JHFileDownloader.h"

@interface JHFileDownloadManager()
@property (strong,  nonatomic) NSMutableDictionary <NSString *, JHFileDownloader *> *loaders;
@end

@implementation JHFileDownloadManager

static JHFileDownloadManager *manager;

+ (instancetype)manager{
    if (!manager) {
        manager = [[JHFileDownloadManager alloc] init];
    }
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [super allocWithZone:zone];
        });
    }
    return manager;
}

- (NSMutableDictionary<NSString *,JHFileDownloader *> *)loaders{
    if (!_loaders) {
        _loaders = @{}.mutableCopy;
    }
    return _loaders;
}

- (JHFileDownloader *)jh_downFileWith:(NSURL *)url{
    NSString *md5String = [url.absoluteString jh_md5String];
    JHFileDownloader *loader = self.loaders[md5String];
    if (loader) {
        [loader jh_resume];
        return loader;
    }
    
    loader = [[JHFileDownloader alloc] init];
    [self.loaders setValue:loader forKey:md5String];
    
    __weak typeof(self) ws = self;
    [loader jh_downFileWith:url progress:^(float progress) {
        
    } success:^(NSString *path) {
        [ws.loaders removeObjectForKey:md5String];
    } failer:^(NSError *error) {
        [ws.loaders removeObjectForKey:md5String];
    }];
    
    return loader;
}

- (void)jh_downFileWith:(NSURL *)url
               progress:(JHFileDownloadingProgress)progress
                success:(JHFileDownloadSuccess)success
                 failer:(JHFileDownloadFailer)failer{
    NSString *md5String = [url.absoluteString jh_md5String];
    JHFileDownloader *loader = self.loaders[md5String];
    if (loader) {
        [loader jh_resume];
        return;
    }
    
    loader = [[JHFileDownloader alloc] init];
    [self.loaders setValue:loader forKey:md5String];
    
    __weak typeof(self) ws = self;
    [loader jh_downFileWith:url progress:^(float _progress) {
        if (progress) {
            progress(_progress);
        }
    } success:^(NSString *path) {
        [ws.loaders removeObjectForKey:md5String];
        if (success) {
            success(path);
        }
    } failer:^(NSError *error) {
        [ws.loaders removeObjectForKey:md5String];
        if (failer) {
            failer(error);
        }
    }];
}

- (void)jh_pause:(NSURL *)url{
    NSString *md5String = [url.absoluteString jh_md5String];
    JHFileDownloader *loader = self.loaders[md5String];
    [loader jh_pause];
}

- (void)jh_resume:(NSURL *)url{
    NSString *md5String = [url.absoluteString jh_md5String];
    JHFileDownloader *loader = self.loaders[md5String];
    [loader jh_resume];
}

- (void)jh_cancel:(NSURL *)url{
    NSString *md5String = [url.absoluteString jh_md5String];
    JHFileDownloader *loader = self.loaders[md5String];
    [loader jh_cancel];
}

- (void)jh_pauseAll{
    [[self.loaders allValues] makeObjectsPerformSelector:@selector(jh_pause)];
}

- (void)jh_cancelAll{
    [[self.loaders allValues] makeObjectsPerformSelector:@selector(jh_cancel)];
}

@end
