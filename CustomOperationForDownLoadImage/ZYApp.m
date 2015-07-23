//
//  ZYApp.m
//  CustomOperationForDownLoadImage
//
//  Created by 王志盼 on 15/7/23.
//  Copyright (c) 2015年 王志盼. All rights reserved.
//

#import "ZYApp.h"

@implementation ZYApp

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]){
        [self setValuesForKeysWithDictionary:dict];
//        NSLog(@"%@----%@---%@",self.icon,self.name,self.download);
    }
    return self;
}

+ (id)appWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
