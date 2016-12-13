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
    NSString *httpUrl = @"http://japi.juhe.cn/book/recommend.from";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"bfb12777f7e63ffcfb88d2dfb9d529c1" forKey:@"key"];
    [JZLNetworkingTool getWithUrl:httpUrl params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        //这里去做成功后返回的数据的处理
        NSLog(@"%@",responseObject);
    } failed:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
