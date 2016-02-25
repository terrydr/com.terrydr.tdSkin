//
//  JRcamera.h
//  JRCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import <Cordova/CDVPlugin.h>

@interface JRcamera : CDVPlugin

//跳转到拍照，视频界面
- (void)jrTakePhotos:(CDVInvokedUrlCommand*)command;
//根据路径删除文件
- (void)jrCleanDataWithPath:(CDVInvokedUrlCommand*)command;
//删除所有文件
- (void)jrCleanAllData:(CDVInvokedUrlCommand*)command;

@end
