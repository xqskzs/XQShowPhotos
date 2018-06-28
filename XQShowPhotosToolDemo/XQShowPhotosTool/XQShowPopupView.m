//
//  XQShowPopupView.m
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/25.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQShowPopupView.h"
#import "XQShowHandle.h"
@interface XQShowPopupView()
{
    CGRect _originRect;
    CGRect _showRect;
}
@property(nonatomic,strong)UIImageView * imgV;
@property(nonatomic,strong)id imgUrl;
@end
@implementation XQShowPopupView

- (instancetype)initWithFrame:(CGRect)frame imgUrl:(id)imgUrl originRect:(CGRect)originRect showRect:(CGRect)showRect
{
    if(self = [super initWithFrame:frame])
    {
        _imgUrl = imgUrl;
        _originRect = originRect;
        _showRect = showRect;
        [self viewInit];
    }
    return self;
}

- (void)viewInit
{
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.imgV];
}

- (UIImageView *)imgV
{
    if(!_imgV)
    {
//      因为imgV的坐标系和window的坐标系对应一致就把转换注释了，如果不一致需要打开注释
//      UIWindow * wd = [[UIApplication sharedApplication].delegate window];
//      _originRect = [wd convertRect:_originRect toView:self];
        _imgV = [[UIImageView alloc] initWithFrame:_originRect];
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
        [XQShowHandle addImage:_imgUrl imageView:_imgV];
    }
    return _imgV;
}

- (void)startAnimation
{
    [UIView animateWithDuration:XQ_KeyboardAnimation_Time animations:^{
        self.imgV.frame = self->_showRect;
    } completion:^(BOOL finished) {
        if(finished)
        {
            if(self.leaveBlock)
                self.leaveBlock();
            [self removeFromSuperview];
        }
    }];
}

@end
