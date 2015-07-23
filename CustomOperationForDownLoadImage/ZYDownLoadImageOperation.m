//
//  ZYDownLoadImageOperation.m
//  CustomOperationForDownLoadImage
//
//  Created by 王志盼 on 15/7/23.
//  Copyright (c) 2015年 王志盼. All rights reserved.
//

#import "ZYDownLoadImageOperation.h"

@implementation ZYDownLoadImageOperation
- (void)main   //重写main方法即可
{
    @autoreleasepool {    //在子线程中，并不会自动添加自动释放池，所以，手动添加，免得MARC的情况下，出现内存泄露的问题
        NSURL *DownLoadUrl = [NSURL URLWithString:self.url];
        if (self.isCancelled) return;          //如果下载操作被取消，那么就无需下面操作了
        NSData *data = [NSData dataWithContentsOfURL:DownLoadUrl];
        if (self.isCancelled) return;
        UIImage *image = [UIImage imageWithData:data];
        if (self.isCancelled) return;
        
        if ([self.delegate respondsToSelector:@selector(DownLoadImageOperation:didFinishDownLoadImage:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{   //回到主线程，更新UI
                [self.delegate DownLoadImageOperation:self didFinishDownLoadImage:image];
            });
        }
    }
}
@end
