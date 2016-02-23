//
//  JRcamera.m
//  JRCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import "JRcamera.h"
#import "WYVideoCaptureController.h"

@interface JRcamera (){
    NSString *_callbackId;
}

@end

@implementation JRcamera

- (void)jrTakePhotos:(CDVInvokedUrlCommand*)command{
    
    _callbackId = command.callbackId;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(takePhotosFinished:)
                                                 name:@"TakePhotosFinishedNotification"
                                               object:nil];
    
    WYVideoCaptureController *videoVC = [[WYVideoCaptureController alloc] init];
    [self.viewController presentViewController:videoVC animated:YES completion:^{
    }];
}

- (void)takePhotosFinished:(NSNotification *)notify{
    NSDictionary *pathDic = notify.userInfo;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:pathDic];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

@end
