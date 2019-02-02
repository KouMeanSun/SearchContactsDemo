//
//  UIImage+BoxBlur.h
//  LiveBlurView
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface UIImage (BoxBlur)

/* blur the current image with a box blur algoritm */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;

/**
 *  @brief  图片拉伸
 *  @return nil
 */
+ (UIImage *)imageStrechFrom:(NSString *)name;
@end
