//
//  JRcamera.m
//  JRCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import "JRcamera.h"
#import "JRMediaFileManage.h"
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
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:pathDic];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
}

- (void)jrCleanDataWithPath:(CDVInvokedUrlCommand*)command{
    NSString *callbackId = command.callbackId;
    NSString *path = [command.arguments objectAtIndex:0];
    JRMediaFileManage *fileManage = [JRMediaFileManage shareInstance];
    BOOL cleanResult = [fileManage deleteFileWithPath:path];
    CDVPluginResult* result;
    if (cleanResult) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean successed!"];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean error!"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)jrCleanAllData:(CDVInvokedUrlCommand*)command{
    NSString *callbackId = command.callbackId;
    JRMediaFileManage *fileManage = [JRMediaFileManage shareInstance];
    BOOL cleanResult = [fileManage deleteAllFiles];
    CDVPluginResult* result;
    if (cleanResult) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean successed!"];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean error!"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end
