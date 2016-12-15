//
//  ViewController.m
//  JZLNetworking
//
//  Created by allenjzl on 2016/12/13.
//  Copyright © 2016年 allenjzl. All rights reserved.
//

#import "ViewController.h"
#import "JZLNetworkingTool.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //post请求
//    NSDictionary * params = @{@"AppKey":@"161250",@"AppSecurity":@"583d1cfe5234e89ea4000001"};
//    [JZLNetworkingTool postWithUrl:@"https://www.corporatetravel.ctrip.com/corpservice/authorize/ticket" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"%@",responseObject);
//    } failed:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"%@",error);
//    }];
    
    //上传
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"WE.jpg" ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [JZLNetworkingTool uploadWithUrl:@"http://localhost" params:nil fileData:data name:@"" fileName:@"WE.jpg" mimeType:@"image/jpeg" progress:^(NSProgress *progress) {
//        
//    } success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"%@",responseObject);
//    } failed:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"%@",error);
//    }];
    
    
//    //下载
    NSString *url = @"http://localhost/test.zip";
    [JZLNetworkingTool downloadWithUrl:url];

}
- (IBAction)pauseDownload:(id)sender {
    [[JZLNetworkingTool sharedManager] pauseDownload];
}
- (IBAction)resumeDownload:(id)sender {
    [[JZLNetworkingTool sharedManager] resumeDownloadprogress:^(NSProgress *progress) {
        
    } success:^(NSURLResponse *response, NSURL *filePath) {
        
    } failed:^(NSError *error) {
        
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
