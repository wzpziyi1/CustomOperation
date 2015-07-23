//
//  ZYApp.h
//  CustomOperationForDownLoadImage
//
//  Created by 王志盼 on 15/7/23.
//  Copyright (c) 2015年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYApp : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *download;

+ (id)appWithDict:(NSDictionary *)dict;
- (id)initWithDict:(NSDictionary *)dict;
@end
