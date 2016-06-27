//
//  TDMediaFileManage.m
//  TDCamera
//
//  Created by 路亮亮 on 16/2/24.
//
//

#import "TDMediaFileManage.h"

@implementation TDMediaFileManage

+ (TDMediaFileManage*)shareInstance
{
    static dispatch_once_t onceToken;
    static TDMediaFileManage* interface = nil;
    dispatch_once(&onceToken, ^{
        interface = [[TDMediaFileManage alloc]init];
    });
    return interface;
}

//获取图片,视频ID
- (NSString *)getMediaId{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

//图片,视频存储路径
- (NSString *)getTDMediaPathWithType:(BOOL)isPicture{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:@"TDMedia"];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        NSError *e = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&e];
    }
    
    NSString *mediaPath;
    if (isPicture) {
        mediaPath = [NSString stringWithFormat:@"%@/%@",path,@"picture"];
    }else{
        mediaPath = [NSString stringWithFormat:@"%@/%@",path,@"video"];
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:mediaPath isDirectory:&isDir]) {
        NSError *e = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaPath withIntermediateDirectories:NO attributes:nil error:&e];
    }
    
    return mediaPath;
}

//根据路径删除文件
- (BOOL)deleteFileWithPath:(NSString *)filePath{
    BOOL isDir = NO;
    BOOL result = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        NSError *e = nil;
        result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&e];
    }
    return result;
}

//删除所有文件
- (BOOL)deleteAllFiles{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [dir stringByAppendingPathComponent:@"TDMedia"];
    BOOL isDir = NO;
    BOOL result = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        NSError *e = nil;
        result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&e];
    }
    return result;
}

@end
