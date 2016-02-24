//
//  WYVideoCaptureController.m
//  WYAVFoundation
//
//  Created by 王俨 on 15/12/31.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYVideoCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Extension.h"
#import "WYVideoTimeView.h"
#import "NSTimer+Addtion.h"
#import "ProgressView.h"
#import "UIView+AutoLayoutViews.h"
//#import "MLSelectPhotoBrowserViewController.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
#define kAnimationDuration 0.2
#define kTimeChangeDuration 0.1
#define kVideoTotalTime 10
#define kVideoLimit 10

@interface WYVideoCaptureController ()<AVCaptureFileOutputRecordingDelegate>
{
    CGRect _leftBtnFrame;
    CGRect _centerBtnFrame;
    CGRect _rightBtnFrame;
    ///  视频录制到第几秒
    CGFloat _currentTime;
    BOOL _isPhoto;
    //视屏最少两秒
    BOOL _isVideoValid;
}
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) WYVideoTimeView *videoTimeView;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *imageViewBtn;
@property (nonatomic, strong) ProgressView *progressView;
@property (nonatomic, strong) UILabel *dotLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIButton *retakeBtn;
@property (nonatomic, strong) UIButton *submitBtn;

//拍摄的照片数组
@property (nonatomic, strong) NSMutableArray *tokenPicturesArr;
/// 负责输入和输出设备之间数据传递
@property (nonatomic, strong) AVCaptureSession *captureSession;
/// 负责从AVCaptureDevice获取数据
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
/// 视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
/// 照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
/// 相机拍摄预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
/// 是否允许旋转 (注意在旋转过程中禁止屏幕旋转)
@property (nonatomic, assign, getter=isEnableRotation) BOOL enableRotation;
/// 旋转前的屏幕大小
@property (nonatomic, assign) CGRect lastBounds;
/// 后台任务标识
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIndentifier;

@end

@implementation WYVideoCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self ChangeToPhoto:YES];
    [self setupCaptureView];
    self.view.backgroundColor = RGB(0x16161b);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_captureSession startRunning];
    [self addOwnTimer];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_captureSession stopRunning];
    [self removeOwnTimer];
}

- (void)dealloc {
    NSLog(@"我是拍照控制器,我被销毁了");
}

- (NSMutableArray *)tokenPicturesArr{
    if (!_tokenPicturesArr) {
        _tokenPicturesArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tokenPicturesArr;
}

- (void)setupCaptureView {
    // 1.初始化会话
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720]; // 设置分辨率
    }
    // 2.获得输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (captureDevice == nil) {
        NSLog(@"获取输入设备失败");
        return;
    }
    // 3.添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    // 4.根据输入设备初始化设备输入对象,用于获得输入数据
    NSError *error = nil;
    _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    AVCaptureDeviceInput *audioCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"创建设备输入对象失败 -- error = %@", error);
        return;
    }
    // 5.初始化视频设备输出对象,用于获得输出数据
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // 初始化图片设备输出对象
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _captureStillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG}; // 输出设置
    // 6.将设备添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    // 7.将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    // 8.创建视频预览层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    CALayer *layer = _viewContainer.layer;
    layer.masksToBounds = YES;
    _captureVideoPreviewLayer.frame = layer.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer insertSublayer:_captureVideoPreviewLayer atIndex:0];
    [self addNotificationToCaptureDevice:captureDevice];
}

#pragma mark - CaptureMethod
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *captureDevice in devices) {
        if (captureDevice.position == position) {
            return captureDevice;
        }
    }
    return nil;
}

/// 改变设备属性的统一方法
///
/// @param propertyChange 属性改变操作
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange {
    AVCaptureDevice *captureDevice = _captureDeviceInput.device;
    NSError *error = nil;
    // 注意:在改变属性之前一定要先调用lockForConfiguration;调用完成之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    } else {
        NSLog(@"更改设备属性错误 -- error = %@", error);
    }
}

#pragma mark - Timer 
- (void)addOwnTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimeChangeDuration target:self selector:@selector(videoTimeChanged:) userInfo:nil repeats:YES];
    [_timer pauseTimer];
}
- (void)removeOwnTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)videoTimeChanged:(NSTimer *)timer {
    _currentTime += kTimeChangeDuration;
    
    if (_currentTime > kVideoTotalTime) {
        if ([_captureMovieFileOutput isRecording]) {
            [_captureMovieFileOutput stopRecording];
        }
        return;
    }
    _progressView.currentTime = _currentTime;
    _videoTimeView.videoTime = _currentTime;
}

#pragma mark - Notification
/// 给输入设备添加通知
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevie {
    // 注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChanged:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevie];
}
/// 移除设备通知
- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

- (void)areaChanged:(NSNotification *)n {
    
}

#pragma mark - SuperMethod
- (BOOL)shouldAutorotate {
    return self.isEnableRotation;
}
/// 屏幕旋转时调整视频预览图层的方向
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    AVCaptureConnection *captureConnection = [_captureVideoPreviewLayer connection];
    captureConnection.videoOrientation = (AVCaptureVideoOrientation)toInterfaceOrientation;
}
/// 旋转后重新设置大小
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _captureVideoPreviewLayer.frame = _viewContainer.bounds;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"视频开始录制");
    [self startVideoRecord];
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"视频录制完成");
    [self endVideoRecord:outputFileURL];
}

#pragma mark - 视频录制
/// 开始录制视频
- (void)startVideoRecord {
    [_cameraBtn setImage:[UIImage imageNamed:@"button_video_screen_stop"] forState:UIControlStateNormal];
    _videoTimeView.videoTime = 0;
    _currentTime = 0;
    _videoTimeView.hidden = NO;
    //_toggleBtn.hidden = YES;
    [_timer resumeTimerAfterTimeInterval:kTimeChangeDuration];
}
/// 结束录制视频
///
/// @param outputFileURL 录制完成的视频的URL
- (void)endVideoRecord:(NSURL *)outputFileURL {
    BOOL canPreview = _currentTime >= 10;
    _progressView.currentTime = 0.0f;
    [self resetVideoRecordCanPreview:canPreview];
    
    if (_isVideoValid) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generateImg.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
        NSError *error = NULL;
        CMTime time = CMTimeMake(0, 60);// 0.0为截取视频1.0秒处的图片，60为每秒60帧
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        NSLog(@"error==%@, Refimage==%@", error, refImg);
        
        UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
        _imageView.image = FrameImage;
        [self.tokenPicturesArr insertObject:FrameImage atIndex:0];
    }
}

- (void)resetVideoRecordCanPreview:(BOOL)canPreview {
    [_timer pauseTimer];
    [_cameraBtn setImage:[UIImage imageNamed:@"button_video_recording_default"] forState:UIControlStateNormal];
    _videoTimeView.hidden = YES;
    _currentTime = 0;
    //_toggleBtn.hidden = canPreview;
    if (!canPreview) {
        [self videoTimeChanged:nil];
    }
}

#pragma mark - UI设计
- (void)setupUI {
    [self prepareUI];
    [self prepareCompleteView];
    
    [self.view addSubview:_closeBtn];
    [self.view addSubview:_toggleBtn];
    [self.view addSubview:_videoTimeView];
    [self.view addSubview:_viewContainer];
    [self.view addSubview:_imageView];
    [self.view addSubview:_imageViewBtn];
    [self.view addSubview:_progressView];
    [self.view addSubview:_dotLabel];
    [self.view addSubview:_leftBtn];
    [self.view addSubview:_centerBtn];
    [self.view addSubview:_rightBtn];
    [self.view addSubview:_cameraBtn];
    
    _closeBtn.frame = CGRectMake(0, 20, 60, 44);
    _toggleBtn.frame = CGRectMake(APP_WIDTH - 60, 20, 60, 44);
    _videoTimeView.frame = CGRectMake((APP_WIDTH - 50) * 0.5, 20, 50, 44);
    _viewContainer.frame = CGRectMake(0, 64, APP_WIDTH, APP_WIDTH);
    _progressView.frame = CGRectMake(0, CGRectGetMaxY(_viewContainer.frame), APP_WIDTH, 5);
    _dotLabel.frame = CGRectMake((APP_WIDTH - 5) * 0.5, APP_WIDTH + 80 , 5, 5);
    CGFloat btnW = 45;
    CGFloat leftBtnX = (APP_WIDTH - 3 * btnW - 2 * 32) *0.5;
    CGFloat leftBtnY = CGRectGetMaxY(_dotLabel.frame) + 6;
    
    _leftBtnFrame = CGRectMake(leftBtnX, leftBtnY, btnW, btnW);
    _centerBtnFrame = CGRectOffset(_leftBtnFrame, 32 + btnW, 0);
    _rightBtnFrame = CGRectOffset(_centerBtnFrame, 32 + btnW, 0);
    [self restoreBtn];
    _cameraBtn.frame = CGRectMake((APP_WIDTH - 67) * 0.5, CGRectGetMaxY(_centerBtnFrame) + 32, 67, 67);
    _imageView.frame = CGRectMake(20, CGRectGetMaxY(_centerBtnFrame) + 32, 60, 60);
    _imageViewBtn.frame = _imageView.frame;
}

- (void)prepareUI {
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _toggleBtn = [[UIButton alloc] init];
    [_toggleBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_toggleBtn addTarget:self action:@selector(takePhotosFinishClick) forControlEvents:UIControlEventTouchUpInside];
    
    _videoTimeView = [[WYVideoTimeView alloc] init];
    _videoTimeView.hidden = YES;
    
    _viewContainer = [[UIView alloc] init];
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = YES;
    
    _imageViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_imageViewBtn addTarget:self
                      action:@selector(imageViewBtnClick:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _progressView = [[ProgressView alloc] initWithFrame:CGRectMake(0, APP_WIDTH + 44, APP_WIDTH, 5)];
    _progressView.totalTime = kVideoTotalTime;
    
    _dotLabel = [[UILabel alloc] init];  // 5 - 5
    _dotLabel.layer.cornerRadius = 2.5;
    _dotLabel.clipsToBounds = YES;
    _dotLabel.backgroundColor = RGB(0xffc437);
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBtn setTitle:@"照片" forState:UIControlStateNormal];
    [_leftBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_centerBtn setTitleColor:RGB(0xffc437) forState:UIControlStateNormal];
    [_centerBtn setTitle:@"照片" forState:UIControlStateNormal];
    _centerBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"短视频" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraBtn setImage:[UIImage imageNamed:@"button_camera_screen"] forState:UIControlStateNormal];
    [_cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraBtn addTarget:self action:@selector(cameraBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
}

- (void)prepareCompleteView {
    
    _retakeBtn = [[UIButton alloc] init];
    [_retakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [_retakeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _retakeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [_retakeBtn addTarget:self action:@selector(retakeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitBtn setImage:[UIImage imageNamed:@"button_screen_complete_submit"] forState:UIControlStateNormal];
    [_submitBtn setImage:[UIImage imageNamed:@"button_screen_complete_submit_click"] forState:UIControlStateHighlighted];
    [_submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ButtonClick
-(void)imageViewBtnClick:(UIButton *)btn{
//    MLSelectPhotoBrowserViewController *browserVc = [[MLSelectPhotoBrowserViewController alloc] init];
//    [browserVc setValue:@(YES) forKeyPath:@"isTrashing"];
//    browserVc.currentPage = 0;
//    browserVc.photos = self.tokenPicturesArr;
//    [self.navigationController pushViewController:browserVc animated:YES];
}
- (void)retakeBtnClick:(UIButton *)btn {
    //_toggleBtn.hidden = NO;
    [self videoTimeChanged:nil];
}
- (void)submitBtnClick:(UIButton *)btn {
    [self closeBtnClick];
}

- (void)closeBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePhotosFinishClick{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"obj" forKey:@"key"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TakePhotosFinishedNotification"
                                                        object:nil
                                                      userInfo:dic];
    [self closeBtnClick];
}

- (void)leftBtnClick:(UIButton *)btn {
    [_centerBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _dotLabel.hidden = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _leftBtn.frame = _centerBtnFrame;
        _centerBtn.frame = _rightBtnFrame;
    } completion:^(BOOL finished) {
        [self ChangeToPhoto:YES];
    }];
}
- (void)rightBtnClick:(UIButton *)btn {
    [_centerBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _dotLabel.hidden = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _rightBtn.frame = _centerBtnFrame;
        _centerBtn.frame = _leftBtnFrame;
    } completion:^(BOOL finished) {
        [self ChangeToPhoto:NO];
    }];
}
- (void)cameraBtnClick:(UIButton *)btn {
    if (_isPhoto) { /// 拍照
        // 1.根据设备输出获得链接
        AVCaptureConnection *captureConnection = [_captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        // 2.根据链接取得设备输出的数据
        [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            _imageView.image = [UIImage imageWithCGImage:[self handleImage:image]];
            [self.tokenPicturesArr insertObject:image atIndex:0];
        }];
    }else{
        /// 视频
        [_captureMovieFileOutput stopRecording];
        if (_currentTime<2.0f) {
            _isVideoValid = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"手指不要放开，视频最短为两秒"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)cameraBtnTouchDown:(UIButton *)btn{
    if (!_isPhoto) {
        _isVideoValid = YES;
        /// 视频
        // 1.根据设备输出获得连接
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        // 2.根据连接取得设备输出的数据
        if (![_captureMovieFileOutput isRecording]) {
            _enableRotation = NO;
            // 2.1如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                _backgroundTaskIndentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            // 2.2预览图层和视屏方向保持一致
            captureConnection.videoOrientation = [_captureVideoPreviewLayer connection].videoOrientation;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"WYMovie.mov"];
            NSURL *fileURL = [NSURL fileURLWithPath:outputFilePath];
            [_captureMovieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        }
    }
}

#pragma mark - private
- (void)restoreBtn {
    _leftBtn.frame = _leftBtnFrame;
    _centerBtn.frame = _centerBtnFrame;
    _rightBtn.frame = _rightBtnFrame;
    _dotLabel.hidden = NO;
    [_centerBtn setTitleColor:RGB(0xffc437) forState:UIControlStateNormal];
}
/// 切换拍照和视频录制
///
/// @param isPhoto YES->拍照  NO->视频录制
- (void)ChangeToPhoto:(BOOL)isPhoto {
    if (isPhoto &&_captureMovieFileOutput.isRecording) {
        [_captureMovieFileOutput stopRecording];
    }
    [self restoreBtn];
    _isPhoto = isPhoto;
    NSString *centerTitle = isPhoto ? @"照片" : @"短视频";
    [_centerBtn setTitle:centerTitle forState:UIControlStateNormal];
    _leftBtn.hidden = isPhoto;
    _rightBtn.hidden = !isPhoto;
    _progressView.hidden = isPhoto;
    
    UIImage *photoImage = [UIImage imageNamed:@"button_camera_screen"];
    UIImage *mvImage = [UIImage imageNamed:@"button_video_recording_default"];
    UIImage *cameraImage = isPhoto ? photoImage : mvImage;
    [_cameraBtn setImage:cameraImage forState:UIControlStateNormal];
}

- (CGImageRef)handleImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.view.size, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, self.view.width, self.view.height)];
    CGImageRef imageRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    CGImageRef subRef = CGImageCreateWithImageInRect(imageRef, CGRectOffset(_viewContainer.frame, 0, 88));
    return subRef;
}


@end
