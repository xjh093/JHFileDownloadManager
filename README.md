# JHFileDownloadManager
文件下载 & 多文件下载 & 断点续传 等等

### use
```
    [[JHFileDownloadManager manager] jh_downFileWith:[NSURL URLWithString:URL] progress:^(float progress) {
        NSLog(@"%@",@(progress));
    } success:^(NSString *path) {
        // path : file in sandbox
        NSLog(@"下载完成 & download success!");
    } failer:^(NSError *error) {
        NSLog(@"下载失败 & download fialer!");
    }];
```
