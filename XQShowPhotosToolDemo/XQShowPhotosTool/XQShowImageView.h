//
//  XQShowImageView.h
//  PlusEV
//
//  Created by 小强 on 2018/6/7.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ToucnBlock)(void);
@interface XQShowImageView : UIView
@property(nonatomic,copy)ToucnBlock endBlock;
@property(nonatomic,copy)ToucnBlock beginBlock;
@property(nonatomic,copy)ToucnBlock moveBlock;
@property(nonatomic,copy)ToucnBlock leaveBlock;
@property(nonatomic,strong)UIImageView * imgView;

- (instancetype)initWithFrame:(CGRect)frame imgUrl:(id)imgUrl size:(CGSize)size;

- (void)beginTouch:(CGPoint)point;

- (void)moveTouch:(CGPoint)curPoint previous:(CGPoint)prePoint;

- (void)endTouch:(CGPoint)curPoint previous:(CGPoint)prePoint;
@end
