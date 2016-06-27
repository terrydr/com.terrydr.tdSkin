//
//  TDMediaFileManage.h
//  TDCamera
//
//  Created by 路亮亮 on 16/2/24.
//
//

#import <Foundation/Foundation.h>

@interface TDMediaFileManage : NSObject

+ (TDMediaFileManage*)shareInstance;
//获取图片,视频ID
- (NSString *)getMediaId;
//图片,视频存储路径
- (NSString *)getTDMediaPathWithType:(BOOL)isPicture;
//根据路径删除文件
- (BOOL)deleteFileWithPath:(NSString *)filePath;
//删除所有文件
- (BOOL)deleteAllFiles;

@end
