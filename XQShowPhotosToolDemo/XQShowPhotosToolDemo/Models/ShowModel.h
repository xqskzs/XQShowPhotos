//
//  ShowModel.h
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/21.
//  Copyright © 2018年 小强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowModel : NSObject

@property(nonatomic,strong)NSMutableArray<id> * show_imgA;//id类型可以是UIImage,url,url字符串

- (CGSize)showImgsVSize;
@end
