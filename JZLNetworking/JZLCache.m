//
//  JZLCache.m
//  JZLNetworking
//
//  Created by allenjzl on 2016/12/18.
//  Copyright © 2016年 allenjzl. All rights reserved.
//

#import "JZLCache.h"
#import <YYCache.h>

@implementation JZLCache

// YYCache 缓存的文件名称(可根据自己项目名称更改),默认缓存在library的cache文件下面

static NSString *const jzlCache = @"jzl_Cache";

static YYCache *_dataCache;

+ (void)initialize  {
    [super initialize];
    _dataCache = [[YYCache alloc] initWithName:jzlCache];
    
}
//存储
+ (void)saveDataCache: (id)data forKey:(NSString *)key {
    [_dataCache setObject:data forKey:key];
    
}
//读取缓存
+ (id)readCache:(NSString *)key {
   return  [_dataCache objectForKey:key];
}

//获取缓存总大小
+ (void)getAllCacheSize {
    unsigned long long diskCache = [_dataCache.diskCache totalCost];
    NSLog(@"%llu",diskCache);
}
//删除指定缓存
+ (void)removeChache:(NSString *)key {
    
    [_dataCache removeObjectForKey:key withBlock:nil];
}
//删除全部缓存
+ (void)removeAllCache {
    
    [_dataCache removeAllObjects];
}



@end
