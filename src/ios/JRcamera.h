//
//  JRcamera.h
//  JRCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import <Cordova/CDVPlugin.h>

@interface JRcamera : CDVPlugin

- (void)jrTakePhotos:(CDVInvokedUrlCommand*)command;

@end
