//
//  XQShowPopupView.h
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/25.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LeaveBlock)(void);

@interface XQShowPopupView : UIView

@property(nonatomic,copy)LeaveBlock leaveBlock;

- (instancetype)initWithFrame:(CGRect)frame imgUrl:(id)imgUrl originRect:(CGRect)originRect showRect:(CGRect)showRect;

- (void)startAnimation;
@end
