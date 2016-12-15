//
//  JZLNetworkingTool.m
//  JZLNetworking
//
//  Created by allenjzl on 2016/12/13.
//  Copyright © 2016年 allenjzl. All rights reserved.
//

#import "JZLNetworkingTool.h"



@implementation JZLNetworkingTool

//单例
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static JZLNetworkingTool *instance;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:@""];
        instance = [[JZLNetworkingTool alloc] initWithBaseURL:baseUrl];
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                   @"text/html",
                                                                                   @"text/json",
                                                                                   @"text/plain",
                                                                                   @"text/javascript",
                                                                                   @"text/xml",
                                                                                   @"image/*"]];
    });
    return instance;
}

- (NSURLSession *)downloadSession
{
    if (_downloadSession == nil) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // nil : nil的效果跟 [[NSOperationQueue alloc] init] 是一样的
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    return _downloadSession;
}



//get请求
+ (void)getWithUrl: (NSString *)url params: (NSDictionary *)params success: (responseSuccess)success failed: (responseFailed)failed  {
    [[JZLNetworkingTool sharedManager] GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功的回调
        if (success) {
            success(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败的回调
        if (failed) {
             failed(task,error);
        }
       
    }];
}

//post请求
+ (void)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(responseSuccess)success failed:(responseFailed)failed {
    [[JZLNetworkingTool sharedManager] POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(task,error);
        }
    }];
}

//文件上传

+ (void)uploadWithUrl: (NSString *)url params: (NSDictionary *)params fileData: (NSData *)fileData name: (NSString *)name fileName: (NSString *)fileName mimeType: (NSString *)mimeType progress: (progress)progress success: (responseSuccess)success failed: (responseFailed)failed {
    [[JZLNetworkingTool sharedManager] POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(task,error);
        }
        
    }];
   
}

//文件下载 支持断点下载
+ (void)downloadWithUrl: (NSString *)url {
    // 1. URL
    NSURL *URL = [NSURL URLWithString:url];
    
    // 2. 发起下载任务
    [JZLNetworkingTool sharedManager].downloadTask = [[JZLNetworkingTool sharedManager].downloadSession downloadTaskWithURL:URL];
    
    // 3. 启动下载任务
    [[JZLNetworkingTool sharedManager].downloadTask resume];
  
}





//暂停下载
- (void)pauseDownload {
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeData = resumeData;
        //将已经下载的数据存到沙盒,下次APP重启后也可以继续下载
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 拼接文件路径   上面获取的文件路径加上文件名
        NSString *path = [@"sssssaad" stringByAppendingString:@".plist"];
        NSString *plistPath = [doc stringByAppendingPathComponent:path];
        self.resumeDataPath = plistPath;
        [resumeData writeToFile:plistPath atomically:YES];
        self.resumeData = resumeData;
        self.downloadTask = nil;
    }];
   
}

//继续下载
- (void)resumeDownloadprogress: (progress)progress success: (downloadSuccess)success failed: (downloadFailed)failed  {
    if (self.resumeData == nil) {
        NSData *resume_data = [NSData dataWithContentsOfFile:self.resumeDataPath];
        if (resume_data == nil) {
            // 即没有内存续传数据,也没有沙盒续传数据,就续传了
            return;
        } else {
            // 当沙盒有续传数据时,在内存中保存一份
            self.resumeData = resume_data;
        }
    }
    
    // 续传数据时,依然不能使用回调
    // 续传数据时起始新发起了一个下载任务,因为cancel方法是把之前的下载任务干掉了 (类似于NSURLConnection的cancel)
    // resumeData : 当新建续传数据时,resumeData不能为空,一旦为空,就崩溃
    // downloadTaskWithResumeData :已经把Range封装进去了
    
    if (self.resumeData != nil) {
        self.downloadTask = [self.downloadSession downloadTaskWithResumeData:self.resumeData];
        // 重新发起续传任务时,也要手动的启动任务
        [self.downloadTask resume];
        
    }
}

#pragma NSURLSessionDownloadDelegate
    
    /// 监听文件下载进度的代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
    {
        // 计算进度
        float downloadProgress = (float)totalBytesWritten / totalBytesExpectedToWrite;
        NSLog(@"%f",downloadProgress);
        
        
    }
    
/// 文件下载结束时的代理方法 (必须实现的)
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // location : 文件下载结束之后的缓存路径
    // 使用session实现文件下载时,文件下载结束之后,默认会删除,所以文件下载结束之后,需要我们手动的保存一份
    NSLog(@"%@",location.path);
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
   // NSString *path = @"/Users/allenjzl/Desktop/ssssss/zzzz.zip";
    // 文件下载结束之后,需要立即把文件拷贝到一个不会销毁的地方
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:[path stringByAppendingString:@"/.zzzzzzz.zip"] error:NULL];
    NSLog(@"%@",path);
}

    

@end
