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
        NSURL *baseUrl = [NSURL URLWithString:@"http://v1594881x7.imwork.net:21815/SpringMVC/"];
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



//get请求
+ (void)getWithUrl: (NSString *)url params: (NSDictionary *)params success: (responseSuccess)success failed: (responseFailed)failed  {
    [[JZLNetworkingTool sharedManager] GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功的回调
        success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败的回调
        failed(task,error);
    }];
}

//post请求
+ (void)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(responseSuccess)success failed:(responseFailed)failed {
    [[JZLNetworkingTool sharedManager] POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(task,error);
    }];
}

//文件上传

+ (void)uploadWithUrl: (NSString *)url params: (NSDictionary *)params fileData: (NSData *)fileData name: (NSString *)name fileName: (NSString *)fileName mimeType: (NSString *)mimeType progress: (progress)progress success: (responseSuccess)success failed: (responseFailed)failed {
    [[JZLNetworkingTool sharedManager] POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed(task,error);
        
    }];
   
}

//文件下载
+ (void)downloadWithUrl: (NSString *)url savePathUrl: (NSURL *)fileUrl progress: (progress)progress success: (downloadSuccess)success failed: (downloadFailed)failed {
    NSURL *urlPath = [NSURL  URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlPath];
    NSURLSessionDownloadTask *downloadTask = [[JZLNetworkingTool sharedManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //可以在此block里面返回主线程去刷新下载进度条
        progress(downloadProgress);
        if (downloadProgress.totalUnitCount == 1) {
            //下载完成清空断点数据
            [JZLNetworkingTool sharedManager].resumeData = nil;
            //清除沙盒文件
            NSFileManager *fileMger = [NSFileManager defaultManager];
            NSString *resumePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[JZLNetworkingTool sharedManager].resumeDataPath];
            if ([fileMger fileExistsAtPath:resumePath]) {
                NSError *err;
                [fileMger removeItemAtPath:resumePath error:&err];
            }
            
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [fileUrl URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failed(error);
        }else {
            //可以根据文件路径拿到下载的文件进行操作,比如显示图片
            success(response,filePath);
            [JZLNetworkingTool sharedManager].dataPath = [filePath absoluteString];
        }
    }];
    [JZLNetworkingTool sharedManager].downloadTask = downloadTask;
    [downloadTask resume];
  
}

//暂停下载
- (void)pauseDownload {
    if (self.downloadTask) {
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            self.resumeData = resumeData;
            //将已经下载的数据存到沙盒,下次APP重启后也可以继续下载
            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            // 拼接文件路径   上面获取的文件路径加上文件名
            NSString *path = [self.dataPath stringByAppendingString:@".plist"];
            NSString *plistPath = [doc stringByAppendingPathComponent:path];
            self.resumeDataPath = plistPath;
            [resumeData writeToFile:plistPath atomically:YES];
            [self.downloadTask suspend];
            self.downloadTask = nil;
        }];
    }

}

//继续下载
- (void)resumeDownloadprogress: (progress)progress success: (downloadSuccess)success failed: (downloadFailed)failed  {
    //先去检查内存中是否有续传文件
    if (self.resumeData == nil) {
        NSData *resume_data = [NSData dataWithContentsOfFile:self.resumeDataPath];
        //如果沙盒和内存都没有,重新下载
        if (resume_data == nil) {
            return;
        }else {
            self.resumeData = resume_data;
        }
    }
    if (self.resumeData != nil && self.downloadTask != nil) {
        self.downloadTask = [[JZLNetworkingTool sharedManager] downloadTaskWithResumeData:self.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            progress(downloadProgress);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL URLWithString:self.dataPath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                failed(error);
            }else {
                success(response,filePath);
            }

        }];
        [self.downloadTask resume];
    }
}














@end
