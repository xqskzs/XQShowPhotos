//
//  XQShowImageView.m
//  PlusEV
//
//  Created by 小强 on 2018/6/7.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQShowImageView.h"
#import "XQShowBackView.h"
#import "XQShowHandle.h"
//长图手指滑动和图片缩放造成的位移不同步，由于时间问题暂时没有处理，影响不大，后期处理
static const float SCALE_RANGE = .8;

static const float LAST_DELTA_PRODUCTS = 2.5;

static const float BACK_ALPHA_SCALE = 1.6;
@interface XQShowImageView()
{
    CGPoint _beginPoint;
    CGFloat _changeY;
    CGFloat _changeX;
    CGFloat _scaleY;
    CGFloat _scaleX;
    BOOL _first;
    NSInteger _plusminusX;
    NSInteger _plusminusY;
    CGFloat _selfH;
    
    id _imgUrl;
    CGSize _size;
}
@end
@implementation XQShowImageView

- (instancetype)initWithFrame:(CGRect)frame imgUrl:(id)imgUrl size:(CGSize)size
{
    if(self = [super initWithFrame:frame])
    {
        _imgUrl = imgUrl;
        _size = size;
        _selfH = frame.size.height;
        [self addSubview:self.imgView];
        _beginPoint = self.imgView.layer.position;
    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (UIImageView *)imgView
{
    if(!_imgView)
    {
        CGFloat imgVY;
        if(self.hh > _size.height)
            imgVY = (self.hh - _size.height)/2;
        else
            imgVY = 0;
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.ww - _size.width)/2, imgVY, _size.width, _size.height)];
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [XQShowHandle addImage:_imgUrl imageView:_imgView];
    }
    return _imgView;
}

- (void)beginTouch:(CGPoint)point
{
    _scaleY = (_beginPoint.y - point.y)/_beginPoint.y * SCALE_RANGE * (self.hh/_selfH);
    _scaleX = (_beginPoint.x - point.x)/_beginPoint.x * SCALE_RANGE * (_selfH/WW) * (self.hh/_selfH);
//    NSLog(@"+++++++++++++++++++++scaleX:%lf,scaleY:%lf",_scaleX,_scaleY);
}

- (void)moveTouch:(CGPoint)curPoint previous:(CGPoint)prePoint
{
    CGPoint delPoint = CGPointMake((curPoint.x - prePoint.x), (curPoint.y - prePoint.y));
    
    _changeY += delPoint.y;
    _changeX += delPoint.x;
    
    if(_changeY > 0 || _first)
    {
        if(!_first)
        {
            _plusminusX = delPoint.x > 0 ? 1 : - 1;
            _plusminusY = delPoint.y > 0 ? 1 : - 1;
            if(_plusminusX * _scaleX > 0)
                _first = YES;
        }
        _changeY = (_changeY > (_selfH) ) ? (_selfH) : _changeY;
        CGFloat changeScale = (_changeY/_selfH) * SCALE_RANGE * (self.hh/_selfH);
        CGFloat scale = 1.0 - changeScale;
//        NSLog(@"++++++++++++++++++++%@,%@,%lf,scale:%lf,changeScale:%lf,changeY:%lf,plusminusX:%d,plusminusY:%d",NSStringFromCGPoint(curPoint),NSStringFromCGPoint(prePoint) ,self.hh,scale,changeScale,_changeY,_plusminusX,_plusminusY);
        
        if(scale <= 1)
        {
            [XQShowBackView shareInstance].alpha = (1 - changeScale * BACK_ALPHA_SCALE * (self.hh/_selfH)) > 0 ? (1 - changeScale * BACK_ALPHA_SCALE * (self.hh/_selfH)) : 0;
            self.imgView.transform = CGAffineTransformMakeScale(scale,scale);
            self.imgView.layer.position = CGPointMake(self.imgView.layer.position.x + delPoint.x * (1 - _scaleX/2 * _plusminusX), self.imgView.layer.position.y + delPoint.y * (1 - _scaleY/2 * _plusminusY));
        }
        else
        {
            self.imgView.layer.position = CGPointMake(self.imgView.layer.position.x + delPoint.x, self.imgView.layer.position.y + delPoint.y);
        }
        UIWindow * wd = [[UIApplication sharedApplication].delegate window];
        if(wd.windowLevel != UIWindowLevelNormal)
            wd.windowLevel = UIWindowLevelNormal;
    }
}

- (void)endTouch:(CGPoint)curPoint previous:(CGPoint)prePoint
{
    [self reset];
    CGPoint delPoint = CGPointMake((curPoint.x - prePoint.x), (curPoint.y - prePoint.y));
    if(fabs(delPoint.x * delPoint.y) > LAST_DELTA_PRODUCTS || fabs(delPoint.x) > LAST_DELTA_PRODUCTS || fabs(delPoint.y) > LAST_DELTA_PRODUCTS)
    {
        if(_leaveBlock)
            _leaveBlock();
    }
    else
    {
        [UIView animateWithDuration:XQ_KeyboardAnimation_Time animations:^{
            self.imgView.layer.position = self->_beginPoint;
            [XQShowBackView shareInstance].alpha = 1;
            UIWindow * wd = [[UIApplication sharedApplication].delegate window];
            wd.windowLevel = UIWindowLevelAlert;
        }];
        self.imgView.transform = CGAffineTransformMakeScale(1,1);
        self.imgView.transform = CGAffineTransformIdentity;
    }
}

- (void)reset
{
    _changeY = 0;
    _changeX = 0;
    _first = NO;
    _scaleX = 0;
    _scaleY = 0;
    _plusminusX = 1;
    _plusminusY = 1;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray * ts = [touches allObjects];
    if(ts.count == 1)
    {
        UITouch * t = ts[0];
        CGPoint curPoint = [t locationInView:self];
       
        [self beginTouch:curPoint];
    }
    if(_beginBlock)
        _beginBlock();
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray * ts = [touches allObjects];
    if(ts.count == 1)
    {
        UITouch * t = ts[0];
        CGPoint curPoint = [t locationInView:self];
        CGPoint prePoint = [t previousLocationInView:self];
       
        [self moveTouch:curPoint previous:prePoint];
    }
    if(_moveBlock)
        _moveBlock();
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray * ts = [touches allObjects];
    UITouch * t = ts[0];
    CGPoint curPoint = [t locationInView:self];
    CGPoint prePoint = [t previousLocationInView:self];
    [self endTouch:curPoint previous:prePoint];

    if(_endBlock)
        self.endBlock();
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self reset];
    if(_endBlock)
        _endBlock();
}
@end
