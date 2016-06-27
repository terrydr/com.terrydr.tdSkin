//
//  TDCamera.h
//  TDCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import <Cordova/CDVPlugin.h>

@interface TDCamera : CDVPlugin

//跳转到拍照，视频界面
- (void)tdTakePhotos:(CDVInvokedUrlCommand*)command;
//根据路径删除文件
- (void)tdCleanDataWithPath:(CDVInvokedUrlCommand*)command;
//删除所有文件
- (void)tdCleanAllData:(CDVInvokedUrlCommand*)command;

@end
