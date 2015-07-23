//
//  ZYDownLoadImageOperation.h
//  CustomOperationForDownLoadImage
//
//  Created by 王志盼 on 15/7/23.
//  Copyright (c) 2015年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZYDownLoadImageOperation;

@protocol ZYDownLoadImageOperationDelegate <NSObject>
@optional
- (void)DownLoadImageOperation:(ZYDownLoadImageOperation *)operation didFinishDownLoadImage:(UIImage *)image;
@end
@interface ZYDownLoadImageOperation : NSOperation
@property (nonatomic, weak) id<ZYDownLoadImageOperationDelegate> delegate;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
