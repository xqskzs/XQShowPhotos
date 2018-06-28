//
//  XQShowHandle.h
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/22.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XQShowHandle : NSObject

+ (void)addImage:(id)object imageView:(UIImageView *)imgV;

+ (NSArray<NSValue *> *)originRects:(UIView *)view total:(NSUInteger)sum;

+ (NSArray<NSValue *> *)imgShowSizes:(UIView *)view total:(NSUInteger)sum;
@end
