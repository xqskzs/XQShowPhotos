//
//  XQShowHandle.m
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/22.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQShowHandle.h"

@implementation XQShowHandle

+ (void)addImage:(id)object imageView:(UIImageView *)imgV
{
    if([object isKindOfClass:[UIImage class]])
    {
        imgV.image = object;
        return;
    }
    if([object isKindOfClass:[NSURL class]])
    {
        [imgV sd_setImageWithURL:object placeholderImage:[UIImage imageNamed:@"ev_square_default"]];
        return;
    }
    if([object isKindOfClass:[NSString class]])
    {
        [imgV sd_setImageWithURL:[NSURL URLWithString:object] placeholderImage:[UIImage imageNamed:@"ev_square_default"]];
    }
}

+ (NSArray<NSValue *> *)originRects:(UIView *)view total:(NSUInteger)sum
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    UIWindow * wd = [[UIApplication sharedApplication].delegate window];
    for (int i = 0 ; i < sum ; i ++) {
        UIView * v = [view viewWithTag:TagNum + i];
        if([v isKindOfClass:[UIImageView class]])
        {
            CGRect rect = [view convertRect:v.frame toView:wd];//这里犯了个错，应该是v的父控件view的坐标系转换到window上。可以直接写v.superview,但我直接写的v
            if(rect.size.width == 0 || rect.size.height == 0)
            {
                CGFloat imgVEdge = (WW - 4 * XQ_CONST_NUM_TEN)/3;
                rect = CGRectMake((WW - imgVEdge/3)/2, (HH - imgVEdge)/2, imgVEdge, imgVEdge);//默认值（在多于n张图片只显示n张的时候，剩下的使用默认居中的区域）
            }
            [array addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    return array;
}

+ (NSArray<NSValue *> *)imgShowSizes:(UIView *)view total:(NSUInteger)sum
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < sum ; i ++) {
        UIView * v = [view viewWithTag:TagNum + i];
        if([v isKindOfClass:[UIImageView class]])
        {
            UIImageView * imgV = (UIImageView *)v;
            CGSize size = [self calculateImgSize:CGSizeMake(WW, 100 * HH) imgSize:imgV.image.size];
            
            [array addObject:[NSValue valueWithCGSize:size]];
        }
    }
    return array;
}

+ (CGSize)calculateImgSize:(CGSize)maxSize imgSize:(CGSize)imgSize//计算每张图在大图浏览时应该显示的尺寸
{
    CGFloat imgW = imgSize.width;
    CGFloat imgH = imgSize.height;
    
    CGFloat maxW = maxSize.width;
    CGFloat maxH = maxSize.height;
    
    if(imgW >= maxW)
    {
        imgH = imgH/(imgW/maxW);
        imgW = maxW;
    }
    else
    {
        if(2 * imgW >= maxW)
        {
            imgH = imgH/(imgW/maxW);
            imgW = maxW;
        }
        else
        {
            imgH = 2 * imgH;
            imgW = 2 * imgW;
        }
    }
    if(imgH > maxH)
    {
        imgW = imgW/(imgH/maxH);
        imgH = maxH;
    }
    return CGSizeMake(imgW, imgH);
}
@end
