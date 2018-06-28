//
//  XQShowBackView.m
//  PlusEV
//
//  Created by 小强 on 2018/6/11.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "XQShowBackView.h"
static XQShowBackView * instance = nil;
@implementation XQShowBackView

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.backgroundColor = [UIColor blackColor];
    });
    return instance;
}

+ (instancetype)shareInstance:(CGRect)frame
{
    [XQShowBackView shareInstance];
    instance.frame = frame;
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return instance;
}
@end
