//
//  JZLNetworkingTool.h
//  JZLNetworking
//
//  Created by allenjzl on 2016/12/13.
//  Copyright © 2016年 allenjzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

//请求成功的回调block
typedef void(^responseSuccess)(NSURLSessionDataTask *task, id  responseObject);

//请求失败的回调block
typedef void(^responseFailed)(NSURLSessionDataTask *task, NSError *error);

//文件下载的成功回调block
typedef void(^downloadSuccess)(NSURLResponse *response, NSURL *filePath);

//文件下载的失败回调block
typedef void(^downloadFailed)( NSError *error);

//文件上传下载的进度block
typedef void (^progress)(NSProgress *progress);

//网络状态管理单例
static AFNetworkReachabilityManager *reachabilityManager;

////网络模式
//typedef enum {
//    JZLNetworkingStatusUnknow = -1,//
//    JZLNetworkingStatusNoNet = 0,
//    JZLNetworkingStatus
//    
//    
//}JZLAFNetworkReachabilityStatus;


@interface JZLNetworkingTool : AFHTTPSessionManager
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
//已经下载的数据
@property (nonatomic, strong) NSData *resumeData;
//文件保存路径
@property (nonatomic, copy) NSString *dataPath;
//续传文件沙盒存储路径
@property (nonatomic, copy) NSString *resumeDataPath;

/**
 管理者单例

 */
+ (instancetype)sharedManager;


/**
 get请求

 @param url 请求url
 @param params 参数
 @param success 成功回调
 @param failed 失败回调
 */
+ (void)getWithUrl: (NSString *)url params: (NSDictionary *)params success: (responseSuccess)success failed: (responseFailed)failed ;


/**
 post请求

 @param url 请求url
 @param params 参数
 @param success 成功回调
 @param failed 失败回调
 */
+ (void)postWithUrl: (NSString *)url params: (NSDictionary *)params success: (responseSuccess)success failed: (responseFailed)failed ;



/**
 文件上传(图片上传)

 @param url 请求url
 @param params 请求参数
 @param fileData 上传文件的二进制数据
 @param name 制定参数名
 @param fileName 文件名(加后缀名)
 @param mimeType 文件类型
 @param progress 上传进度
 @param success 成功回调
 @param failed 失败回调
 */
+ (void)uploadWithUrl: (NSString *)url params: (NSDictionary *)params fileData: (NSData *)fileData name: (NSString *)name fileName: (NSString *)fileName mimeType: (NSString *)mimeType progress: (progress)progress success: (responseSuccess)success failed: (responseFailed)failed;


/**
 文件下载

 @param url 网络请求url
 @param fileUrl 保存文件url
 @param progress 下载进度
 @param success 成功回调
 @param failed 失败回调

 */
+ (void)downloadWithUrl: (NSString *)url savePathUrl: (NSURL *)fileUrl progress: (progress)progress success: (downloadSuccess)success failed: (downloadFailed)failed;

/**
 暂停下载
 */
- (void)pauseDownload;


/**
 继续下载(断点下载)

 @param progress 下载进度
 @param success 成功回调
 @param failed 失败回调
 */
- (void)resumeDownloadprogress: (progress)progress success: (downloadSuccess)success failed: (downloadFailed)failed ;

@end
