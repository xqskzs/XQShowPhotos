//
//  XQShowPhotosView.h
//  PlusEV
//
//  Created by 小强 on 2018/6/1.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XQShowPhotosView : UIView
typedef void (^LeaveBlock)(void);

@property(nonatomic,copy)LeaveBlock leaveBlock;

- (instancetype)initWithFrame:(CGRect)frame pictureA:(NSArray *)pictureA currentPage:(NSUInteger)currentPage originRects:(NSArray<NSValue *> *)originRectA imgShowSizes:(NSArray<NSValue *> *)showSizeA;
@end
