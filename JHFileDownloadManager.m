//
//  JHFileDownloadManager.m
//  JHKit
//
//  Created by HaoCold on 2017/9/22.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

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
