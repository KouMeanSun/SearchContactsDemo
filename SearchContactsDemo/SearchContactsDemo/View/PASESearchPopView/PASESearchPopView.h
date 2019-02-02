//
//  PASESearchPopView.h
//  PASEBussinessOff
//
//  Created by gaomingyang on 2019/7/2.
//  Copyright © 2019年 gaomingyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASEContactsCell.h"
@interface PASESearchPopView : UIView
@property (nonatomic,assign) CGFloat animationTime;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic,assign) PASEContactsCellStyle cellStyle;
@property (nonatomic,copy) void(^selectPopElement)(PASEContactsModel * model);

/**展示tableView
 @param PASEArray dataSource */
- (void)showThePopViewWithPASEArray:(NSMutableArray *)PASEArray;
/** *  移除popView */
- (void)dismissThePopView;

- (instancetype)initWithAttributeBlock:(void(^)(PASESearchPopView * popView))attributeBlock;

- (void)reloadTableView;

@end
