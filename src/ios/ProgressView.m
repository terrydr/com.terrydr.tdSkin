//
//  PregressView.m
//  ProgressView
//
//  Created by yuelixing on 15/5/28.
//  Copyright (c) 2015年 yuelixing. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()

@property (nonatomic, retain) CAShapeLayer * shapeLayer;
@property (nonatomic, retain) CAShapeLayer * backLayer;

@end

@implementation ProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.backLayer];
        [self.layer addSublayer:self.shapeLayer];
        self.progress = 0;
    }
    return self;
}

- (void)setCurrentTime:(CGFloat)currentTime {
    _currentTime = currentTime;
    self.progress = _currentTime/self.totalTime;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    _shapeLayer.strokeStart = _progress/2.0;
    _shapeLayer.strokeEnd = 1.0-(_progress/2.0f);
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        
        
        // 创建出贝塞尔曲线
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
        
        // 贝塞尔曲线与CAShapeLayer产生关联
        _shapeLayer.path = path.CGPath;
        
        // 基本配置
        _shapeLayer.fillColor   = RGB(0x2c2d32).CGColor;
        _shapeLayer.lineWidth   = self.frame.size.height;
        _shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
        _shapeLayer.strokeEnd   = 0.f;
        
    }
    return _shapeLayer;
}

- (CAShapeLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAShapeLayer layer];
        _backLayer.frame = self.bounds;
        
        // 创建出贝塞尔曲线
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
        
        // 贝塞尔曲线与CAShapeLayer产生关联
        _backLayer.path = path.CGPath;
        
        // 基本配置
        _backLayer.strokeColor   = RGB(0x2c2d32).CGColor;
        _backLayer.lineWidth   = self.frame.size.height;
        _backLayer.strokeEnd   = 1;
    }
    return _backLayer;
}

@end
