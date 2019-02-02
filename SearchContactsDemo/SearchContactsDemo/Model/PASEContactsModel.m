//
//  PASEContactsModel.m
//  PASEBussinessOff
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import "PASEContactsModel.h"

@implementation PASEContactsModel

- (instancetype)initWithName:(NSString *)name mobileNum:(NSString *)mobileNum image:(NSString *)image{
    if (self == [super init]) {
        self = [super init];
        self.name = name;
        self.mobile = mobileNum;
        self.image = image;
    }
    return self;
}

@end
