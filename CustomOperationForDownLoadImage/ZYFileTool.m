//
//  ZYFileTool.m
//  Template
//
//  Created by 王志盼 on 15/10/9.
//  Copyright © 2015年 王志盼. All rights reserved.
//

#import "ZYFileTool.h"

@implementation ZYFileTool

+ (NSString *)getRootPath:(ZYFileToolType)type
{
    switch (type) {
        case ZYFileToolTypeDocument:
            return [self getDocumentPath];
            break;
        case ZYFileToolTypeCache:
            return [self getCachePath];
            break;
        case ZYFileToolTypeLibrary:
            return [self getLibraryPath];
            break;
        case ZYFileToolTypeTmp:
            return [self getTmpPath];
            break;
        default:
            break;
    }
    return nil;
}

+ (NSString *)getDocumentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
}

+ (NSString *)getCachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)getLibraryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)getTmpPath
{
    return NSTemporaryDirectory();
}

+ (BOOL)fileIsExists:(NSString *)path
{
    if (path == nil || path.length == 0) {
        return false;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+ (NSString *)createFileName:(NSString *)fileName  type:(ZYFileToolType)type context:(NSData *)context
{
    if (fileName == nil || fileName.length == 0) {
        return nil;
    }
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *path = [[self getRootPath:type] stringByAppendingPathComponent:fileName];
    if (![self fileIsExists:path])
    {
//        if (![[NSFileManager defaultManager] removeItemAtPath:path error:nil]) {
//            return nil;
//        }
        [[NSFileManager defaultManager] createFileAtPath:path contents:context attributes:nil];
    }
    
    return path;
}

+ (NSData *)readDataWithFileName:(NSString *)fileName type:(ZYFileToolType)type
{
    if (fileName == nil || fileName.length == 0) {
        return nil;
    }

    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *path = [[self getRootPath:type] stringByAppendingPathComponent:fileName];
    
    if ([self fileIsExists:path])
    {
        return [[NSFileManager defaultManager] contentsAtPath:path];
    }
    return nil;
}

@end
