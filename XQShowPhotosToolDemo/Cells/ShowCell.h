//
//  ShowCell.h
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/21.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowModel.h"
@class ShowCell;
@protocol ShowCellDelegate<NSObject>
@optional
- (void)cell:(ShowCell *)cell imgs:(NSArray *)imgA index:(NSUInteger)index originRects:(NSArray<NSValue *> *)originRectA imgShowSizes:(NSArray<NSValue *> *)showSizeA;
@end
@interface ShowCell : UITableViewCell

@property(nonatomic,weak)id<ShowCellDelegate> delegate;
- (void)setInfoModel:(ShowModel *)model;
@end
