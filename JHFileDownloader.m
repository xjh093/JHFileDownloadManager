//
//  JHFileDownloader.m
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

#import "JHFileDownloader.h"
#import "NSString+JHFileDownloader.h"
#import "JHFileDownloader+FileManager.h"

#define kCacheDoc NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpDoc NSTemporaryDirectory()

@interface JHFileDownloader()<NSURLSessionDataDelegate>
/// current downloading progress
@property (assign,  nonatomic) float progress;
/// temp file size
@property (assign,  nonatomic) long long tempFileSize;
/// file total size
@property (assign,  nonatomic) long long totalFileSize;
/// temp file path
@property (copy,    nonatomic) NSString *tempFilePath;
/// cache file path
@property (copy,    nonatomic) NSString *cacheFilePath;
/// download session
@property (strong,  nonatomic) NSURLSession *session;
/// data write
@property (strong,  nonatomic) NSOutputStream *outPutStream;
/// download task
@property (strong,  nonatomic) NSURLSessionDataTask *task;
@end

@implementation JHFileDownloader

///
- (void)jh_downFileWith:(NSURL *)url
               progress:(JHFileDownloadingProgress)progress
                success:(JHFileDownloadSuccess)success
                 failer:(JHFileDownloadFailer)failer
{
    _downloadingProgress = progress;
    _downloadSuccess     = success;
    _downloadFailer      = failer;
    
    [self jh_downFileWith:url];
}

/// based on the url to download files
- (void)jh_downFileWith:(NSURL *)url{
    
    //
    _tempFilePath = [kTmpDoc stringByAppendingPathComponent:[url.absoluteString jh_md5String]];
    _cacheFilePath = [kCacheDoc stringByAppendingPathComponent:url.lastPathComponent];
    
    //file exist
    if ([self jh_isFileExist:_cacheFilePath]) {
        self.state = JHFileDownloadStateSuccess;
        
        if (_downloadSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _downloadSuccess(_cacheFilePath);
            });
        }
        
        _size = [self jh_fileSize:_cacheFilePath];
        
        if (_downloadingSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _downloadingSize(_size);
            });
        }
        
        return;
    }
    
    //task exist
    if ([url isEqual:_task.originalRequest.URL]) {
        if (_state == JHFileDownloadStateDowning) {
            return;
        }else if (_state == JHFileDownloadStatePause){
            [self jh_resume];
            return;
        }
    }
    
    //task not exist
    [self jh_cancel];
    _tempFileSize = [self jh_fileSize:_tempFilePath];
    
    //
    [self xx_download:url];
}

/// pause download task
- (void)jh_pause{
    if (_state == JHFileDownloadStateDowning) {
        [_task suspend];
        self.state = JHFileDownloadStatePause;
    }
}

/// resume download task
- (void)jh_resume{
    if (_state == JHFileDownloadStatePause) {
        [_task resume];
        self.state = JHFileDownloadStateDowning;
    }
}

/// cancel download task
- (void)jh_cancel{
    [self.session invalidateAndCancel];
    self.session = nil;
    
    //remove temp file
    [self jh_removeFile:_tempFilePath];
}

/// download start
- (void)xx_download:(NSURL *)url
{
    //http header : Range "bytes=开始字节-结束字节"
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",_tempFileSize] forHTTPHeaderField:@"Range"];
    _task = [self.session dataTaskWithRequest:request];
    [_task resume];
}

#pragma mark - NSURLSessionDataDelegate 

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"response:%@",response);
    
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeString = httpResponse.allHeaderFields[@"Content-Range"];
        _totalFileSize = [[[rangeString componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    _size = _totalFileSize;
    
    //
    if (_tempFileSize == _totalFileSize) {
        self.state = JHFileDownloadStateSuccess;
        //move
        [self jh_moveFile:_tempFilePath to:_cacheFilePath];
        //cancel request
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    //
    if (_tempFileSize > _totalFileSize) {
        //remove
        [self jh_removeFile:_tempFilePath];
        //cancel request
        completionHandler(NSURLSessionResponseCancel);
        //request again
        _tempFileSize = 0;
        [self xx_download:response.URL];
        return;
    }
    
    //
    self.state = JHFileDownloadStateDowning;
    _outPutStream = [NSOutputStream outputStreamToFileAtPath:_tempFilePath append:YES];
    [_outPutStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    _tempFileSize += data.length;
    //NSLog(@"_tempFileSize:%lld,_totalFileSize:%lld",_tempFileSize,_totalFileSize);
    self.progress = _tempFileSize * 1.0 / _totalFileSize;
    [_outPutStream write:data.bytes maxLength:data.length];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [_outPutStream close];
    _outPutStream = nil;
    
    if (!error) {
        [self jh_moveFile:_tempFilePath to:_cacheFilePath];
        self.state = JHFileDownloadStateSuccess;
        if (_downloadSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _downloadSuccess(_cacheFilePath);
            });
        }
    }else{
        self.state = JHFileDownloadStateFailer;
        if (_downloadFailer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _downloadFailer(error);
            });
        }
    }
}

#pragma mark - lazy load

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

#pragma mark - setter

- (void)setState:(JHFileDownloadState)state{
    if (_state == state) {
        return;
    }
    
    _state = state;
    
    if (_downloadStateChange) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _downloadStateChange(state);
        });
    }
}

- (void)setProgress:(float)progress{
    _progress = progress;
    //NSLog(@"%f",progress);
    if (_downloadingProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _downloadingProgress(progress);
        });
    }
}

@end


