//
//  UITextField (RAC)
//  SSSearcher
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (RAC)
@property(nonatomic,copy)void(^editTextHandler)(NSString *text);
@end
