//
//  JRcamera.m
//  JRCamera
//
//  Created by 路亮亮 on 16/2/18.
//
//

#import "JRcamera.h"
#import "WYVideoCaptureController.h"

@implementation JRcamera

- (void)jrTakePhotos:(CDVInvokedUrlCommand*)command{
    WYVideoCaptureController *videoVC = [[WYVideoCaptureController alloc] init];
    [self.viewController presentViewController:videoVC animated:YES completion:^{
    }];
}

@end
