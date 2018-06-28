//
//  ShowModel.m
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/21.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "ShowModel.h"

@implementation ShowModel

- (CGSize)showImgsVSize
{
    CGFloat imagesVH;
    CGFloat imagesVW;
    NSUInteger imgNum = self.show_imgA.count;
    NSUInteger imgCount = self.show_imgA.count > 3 ? 3 : self.show_imgA.count;
    
    imagesVW = (WW - (imgCount + 1) * ImgSpace)/imgCount;
    
    if(imgNum <= imgCount)
    {
        imagesVH = imagesVW;
    }
    else
    {
        NSUInteger j = imgNum/LineNum + (imgNum%LineNum ? 1 : 0);//三目运算切记加括号，不然很难发现问题
        imagesVH = j * imagesVW + (j - 1) * ImgSpace;
    }
    return CGSizeMake(imagesVW, imagesVH);
}
@end
