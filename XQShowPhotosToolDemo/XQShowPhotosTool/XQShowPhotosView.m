//
//  XQShowPhotosView.m
//  PlusEV
//
//  Created by 小强 on 2018/6/1.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQShowPhotosView.h"
#import "XQShowImageView.h"
#import "XQShowScrollView.h"
#import "XQShowBackView.h"
static const float MIN_SCALE = 1.0;
static const float MAX_SCALE = 2.0;

@interface XQShowPhotosView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIScrollView * _scrollV;
    UIPageControl * _pageC;
    NSUInteger _n;
    NSUInteger _page;
    BOOL _isBeginMove;
    BOOL _isEndMove;
    BOOL _isBeginZoom;
    CGPoint _prePoint;
}
@property(nonatomic,strong)NSArray * pictureA;
@property(nonatomic,strong)NSArray * originRectA;
@property(nonatomic,strong)NSArray * showSizeA;
@property(nonatomic,assign)NSUInteger currentPage;
@end
@implementation XQShowPhotosView

- (instancetype)initWithFrame:(CGRect)frame pictureA:(NSArray *)pictureA currentPage:(NSUInteger)currentPage originRects:(NSArray<NSValue *> *)originRectA imgShowSizes:(NSArray<NSValue *> *)showSizeA
{
    if(self = [super initWithFrame:frame])
    {
        _pictureA = pictureA;
        _n = _pictureA.count;
        _currentPage = currentPage;
        _page = _currentPage;
        _originRectA = originRectA;
        _showSizeA = showSizeA;
        [self viewInit];
    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}

-(void)viewInit
{
    XQShowBackView * backView = [XQShowBackView shareInstance:self.frame];
    backView.alpha = 1.0;
    [self addSubview:backView];
    CGFloat pageCH = 20;
    _page = (int)_currentPage;
    _scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WW, self.hh)];
    _scrollV.delegate = self;
    _scrollV.pagingEnabled = YES;
    _scrollV.bounces = YES;
    _scrollV.showsHorizontalScrollIndicator = NO;
    _scrollV.showsVerticalScrollIndicator = NO;
    
    [self addSubview:_scrollV];
    
    _scrollV.contentSize = CGSizeMake(WW*_n, self.hh);
    
    for(NSUInteger i=0; i< _n;i++)
    {
        CGSize size = [_showSizeA[i] CGSizeValue];
        XQShowScrollView * sv = [[XQShowScrollView alloc] initWithFrame:CGRectMake(i * WW,0,WW,self.hh)];
        sv.backgroundColor = [UIColor clearColor];
        sv.contentSize = size;
        sv.delegate = self;
        sv.minimumZoomScale = MIN_SCALE;
        sv.maximumZoomScale = MAX_SCALE;
        sv.zoomScale = 1.0;
        sv.tag = TagNum + i;
        sv.showsHorizontalScrollIndicator = NO;
        sv.showsVerticalScrollIndicator = NO;
        sv.bounces = YES;
        
        id object = _pictureA[i];
        XQShowImageView * imgV = [[XQShowImageView alloc]initWithFrame:CGRectMake(0, 0, WW, self.hh) imgUrl:object size:size];
        imgV.moveBlock = ^{
            [self inScrollEnabled:NO];
            [self outScrollEnabled:NO];
        };
        imgV.endBlock = ^{
            [self inScrollEnabled:YES];
            [self outScrollEnabled:YES];
        };
        imgV.leaveBlock = ^{
            [self tap1:nil];
        };
        imgV.tag = TagNum * 2;
        [sv addSubview:imgV];
        [_scrollV addSubview:sv];
    }
    UITapGestureRecognizer * tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
    [self addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)];
    tapGesture2.numberOfTapsRequired = 2;
    [tapGesture1 requireGestureRecognizerToFail:tapGesture2];
    [self addGestureRecognizer:tapGesture2];
    
    UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    longGesture.minimumPressDuration = .6f;
    longGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longGesture];
   
    
    CGRect r = CGRectMake(_currentPage*WW,0, WW, self.hh);
    [_scrollV scrollRectToVisible:r animated:NO];
    
    _pageC = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.hh - pageCH, WW, pageCH)];
    _pageC.numberOfPages = _n;
    _pageC.pageIndicatorTintColor = [UIColor grayColor];
    _pageC.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageC.currentPage = _currentPage;
    _pageC.hidden = _n == 1;
    [self addSubview:_pageC];
}

- (void)outScrollEnabled:(BOOL)isEnabled
{
    _scrollV.scrollEnabled = isEnabled;
}

- (void)inScrollEnabled:(BOOL)isEnabled
{
    UIScrollView * sv = [_scrollV viewWithTag:_page + TagNum];
    sv.scrollEnabled = isEnabled;
}

#pragma mark --------------- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_isBeginZoom)
    {
        CGSize size = [_showSizeA[_page] CGSizeValue];
        CGFloat contentH = scrollView.contentSize.height;
        CGFloat minOffsetY;
        if(size.height * scrollView.zoomScale <= HH)
        {
            minOffsetY = (contentH - HH)/2;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, minOffsetY);
        }
        else
        {
            minOffsetY = 0;
            if(scrollView.contentOffset.y <= 0)
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
            if(scrollView.contentOffset.y >= contentH - HH)
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, contentH - HH);
        }
     
        if(scrollView.contentOffset.y <= minOffsetY && [scrollView isKindOfClass:[XQShowScrollView class]])
        {
            if(!_isEndMove)
            {
                XQShowImageView * showImgV = [scrollView viewWithTag:TagNum * 2];
                
                CGPoint point = [scrollView.panGestureRecognizer locationInView:scrollView];
                
                CGPoint curPoint = [scrollView convertPoint:point toView:showImgV];
                
                if(!_isBeginMove)
                {
                    _isBeginMove = YES;
                    [showImgV beginTouch:curPoint];
                    _prePoint = CGPointMake(curPoint.x, curPoint.y);
                }
                else
                {
                    [showImgV moveTouch:curPoint previous:_prePoint];
                    _prePoint = CGPointMake(curPoint.x, curPoint.y);
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //下面三个打印为了找到scrollView.contentOffset.y可能不为minOffsetY的情况，所以把第一层的条件scrollView.contentOffset.y <= minOffsetY换成了_isBeginMove
//    NSLog(@"++++++++++++++oudend,%lf,%lf",scrollView.contentOffset.y,scrollView.zoomScale);

    if(_isBeginMove)
    {
//        NSLog(@"++++++++++++++midend");

        if([scrollView isKindOfClass:[XQShowScrollView class]])
        {
            _isBeginMove = NO;
            _isEndMove = YES;

            XQShowImageView * showImgV = [scrollView viewWithTag:TagNum * 2];
            
            CGPoint curPoint = [scrollView.panGestureRecognizer locationInView:showImgV];
            CGPoint prePoint;
            CGPoint veloctyPoint = [scrollView.panGestureRecognizer velocityInView:self];
            
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);

            if(decelerate && x < y)
            {
                if(scrollView.zoomScale > MIN_SCALE)
                {
                    if(scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width - WW)
                    {
                        prePoint = CGPointMake(curPoint.x + 2, curPoint.y + 2);
                    }
                    else
                    {
                        prePoint = curPoint;
                    }
                }
                else
                {
                    prePoint = CGPointMake(curPoint.x + 2, curPoint.y + 2);
                }
            }
            else
            {
                prePoint = curPoint;
            }
            [showImgV endTouch:curPoint previous:prePoint];
//            NSLog(@"++++++++++++++inend");
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([scrollView isKindOfClass:[XQShowScrollView class]])
    {
        _isEndMove = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == _scrollV)
    {
        int page = scrollView.contentOffset.x/WW;
//        if(page != _page)
//        {
//            for (UIView * sv in scrollView.subviews) {
//                if([sv isKindOfClass:[UIScrollView class]])
//                {
//                    [(UIScrollView *)sv setZoomScale:MIN_SCALE];
//                }
//            }
//        }
        _page = page;
        _pageC.currentPage = _page;
    }
    if([scrollView isKindOfClass:[XQShowScrollView class]])
    {
        _isEndMove = NO;
    }
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    for (UIView * v in scrollView.subviews) {
        v.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
        return;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _isBeginZoom = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _isBeginZoom = NO;
    CGSize size = [_showSizeA[_page] CGSizeValue];
    if(size.height * 2 > scrollView.contentSize.height)
    {
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, size.height * scrollView.zoomScale);
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (UIView * v in scrollView.subviews) {
        return v;
    }
    return nil;
}
#pragma mark --------------- Action
-(void)tap1:(UITapGestureRecognizer *)tapGesture
{
    if(_leaveBlock)
        _leaveBlock();
    
    UIScrollView * sv = [_scrollV viewWithTag:_page + TagNum];
    if(sv.zoomScale != MIN_SCALE)
       [sv setZoomScale:MIN_SCALE animated:NO];
    XQShowImageView * imgV = [sv viewWithTag:TagNum * 2];
    CGRect originFrame = [_originRectA[_page] CGRectValue];
//      因为imgV的坐标系和window的坐标系对应一致就把转换注释了，如果不一致需要打开注释
//      UIWindow * wd = [[UIApplication sharedApplication].delegate window];
//      originFrame = [wd convertRect:originFrame toView:imgV];
    imgV.imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgV.imgView.layer.masksToBounds = YES;
    [UIView animateWithDuration:XQ_KeyboardAnimation_Time animations:^{
        imgV.imgView.frame = originFrame;
        [XQShowBackView shareInstance].alpha = 0;
    } completion:^(BOOL finished) {
        if(finished)
        {
            [self removeFromSuperview];
        }
    }];
}
-(void)tap2:(UITapGestureRecognizer *)tapGesture
{
    UIScrollView * sv = [_scrollV viewWithTag:_page + TagNum];

    if(sv.zoomScale > MIN_SCALE)
    {
        [sv setZoomScale:MIN_SCALE animated:YES];
    }
    else
    {
        [sv setZoomScale:MAX_SCALE animated:YES];
    }
}

- (void)longTapAction:(UILongPressGestureRecognizer *)longGesture
{
//    NSLog(@"++++++++++++++++++++longTap");

    if(longGesture.state == UIGestureRecognizerStateBegan)
    {
        UIScrollView * sv = [_scrollV viewWithTag:_page + TagNum];
        XQShowImageView * showView = [sv viewWithTag:2 * TagNum];
        if(_longTapBlock)
            _longTapBlock(showView.imgView.image);
    }
}
@end
