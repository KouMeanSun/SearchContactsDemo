//
//  NSString+chineseTransform.h
//  PASEBussinessOff
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (chineseTransform)

/**
 汉字转pinyin

 @param chineseString 中文汉字
 @return 拼音字母
 */
+ (NSString *)chinese_Pinyin:(NSString *)chineseString;


/**
 匹配汉字高亮效果的attributeString
 */
+ (NSMutableAttributedString *)lightStringWithSearchResultName:(NSString *)searchResultName matchPASEArray:(NSArray *)matchPASEArray inputString:(NSString *)inputString lightedColor:(UIColor *)lightedColor;
@end
