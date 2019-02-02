//
//  UIButton+Block.h
//  PASEBussinessOff
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Block)
@property(nonatomic,copy)void(^actionBlock)(UIButton *);
-(void)addTargetActionBlock:(void(^)(UIButton *btn))block;
- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color;
@end
