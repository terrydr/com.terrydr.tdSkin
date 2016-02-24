//
//  JRMediaFileManage.h
//  JRCamera
//
//  Created by 路亮亮 on 16/2/24.
//
//

#import <Foundation/Foundation.h>

@interface JRMediaFileManage : NSObject

+ (JRMediaFileManage*)shareInstance;
//获取图片,视频ID
- (NSString *)getMediaId;
//图片,视频存储路径
- (NSString *)getJRMediaPathWithType:(BOOL)isPicture;

@end
