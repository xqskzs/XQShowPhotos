//
//  ShowCell.m
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/21.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "ShowCell.h"
#import "XQShowHandle.h"

@interface ShowCell()
@property(nonatomic,strong)ShowModel * model;
@property(nonatomic,strong)UIView * imagesView;

@end
@implementation ShowCell


- (void)setInfoModel:(ShowModel *)model
{
    if(!_model)
    {
        [self viewInit];
    }
    [self dataInit:model];
}

- (void)viewInit
{
    _imagesView = [[UIView alloc] init];
    [self.contentView addSubview:_imagesView];
}

- (void)dataInit:(ShowModel *)model
{
    _model = model;
    [_imagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize imgVSize = [model showImgsVSize];
    
    _imagesView.frame = CGRectMake(0, 0, WW, imgVSize.height);
    
    for(int i = 0 ; i < model.show_imgA.count ; i ++)
    {
        id object = _model.show_imgA[i];
        UIImageView * imgV = [[UIImageView alloc]initWithFrame:CGRectMake((i%LineNum) * (imgVSize.width + ImgSpace) + ImgSpace,(i/LineNum) * (imgVSize.width + ImgSpace), imgVSize.width, imgVSize.width)];
        [XQShowHandle addImage:object imageView:imgV];
        imgV.layer.masksToBounds = YES;
        [imgV setContentMode:UIViewContentModeScaleAspectFill];
        imgV.tag = TagNum + i;
        [_imagesView addSubview:imgV];
    }
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPhothosTap:)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    [_imagesView addGestureRecognizer:tapGesture];
}

- (void)showPhothosTap:(UITapGestureRecognizer *)tap
{
    NSUInteger ntag;
    CGPoint point = [tap locationInView:_imagesView];
    for (UIView *imgView in _imagesView.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            //判断触摸点是否落在某一张图片的上面
            if (CGRectContainsPoint(imgView.frame, point)) {
                ntag = imgView.tag;
                if(self.delegate && [self.delegate respondsToSelector:@selector(cell:imgs:index:originRects:imgShowSizes:)])
                {
                    [self.delegate cell:self imgs:_model.show_imgA index:ntag - TagNum originRects:[XQShowHandle originRects:_imagesView total:_model.show_imgA.count] imgShowSizes:[XQShowHandle imgShowSizes:_imagesView total:_model.show_imgA.count]];
                }
                break;
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
