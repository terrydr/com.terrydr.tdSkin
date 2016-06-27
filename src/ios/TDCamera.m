//
//  TDCamera.m
//  TDCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import "TDCamera.h"
#import "TDMediaFileManage.h"
#import "WYVideoCaptureController.h"

@interface TDCamera (){
    NSString *_callbackId;
}

@end

@implementation TDCamera

- (void)tdTakePhotos:(CDVInvokedUrlCommand*)command{
    
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

- (void)tdCleanDataWithPath:(CDVInvokedUrlCommand*)command{
    NSString *callbackId = command.callbackId;
    NSString *path = [command.arguments objectAtIndex:0];
    TDMediaFileManage *fileManage = [TDMediaFileManage shareInstance];
    BOOL cleanResult = [fileManage deleteFileWithPath:path];
    CDVPluginResult* result;
    if (cleanResult) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean successed!"];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"clean error!"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)tdCleanAllData:(CDVInvokedUrlCommand*)command{
    NSString *callbackId = command.callbackId;
    TDMediaFileManage *fileManage = [TDMediaFileManage shareInstance];
    BOOL cleanResult = [fileManage deleteAllFiles];
    CDVPluginResult* result;
    if (cleanResult) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"clean successed!"];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"clean error!"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end
