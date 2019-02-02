//
//  PASEContactsCell.h
//  PASEBussinessOff
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASEContactsModel.h"
typedef NS_ENUM (NSInteger,PASEContactsCellStyle) {
    /// 默认展示拨打电话
    PASEContactsCellStyleDefault,
    /// 展示勾选
    PASEContactsCellStyleDis_correct,

} ;

@interface PASEContactsCell : UITableViewCell
@property(nonatomic,copy)void(^callPhoneBlock)(NSString *phoneNum);
@property (nonatomic,strong) UILabel *nameComponent;
@property (nonatomic,strong) UILabel *nameLbl;
@property (nonatomic,strong) UIButton * callPhoneBtn;
@property (nonatomic,strong) UIButton * correctBtn;
@property (nonatomic,strong) PASEContactsModel * model;
@property (nonatomic,assign) PASEContactsCellStyle cellStyle;

- (instancetype)initWithPASEFrecontCellStyle:(PASEContactsCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setCellAttributeString:(NSMutableAttributedString *)attributeString;
@end
