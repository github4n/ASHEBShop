//
//  ASHSearchTagView.h
//  ASHEBShop
//
//  Created by xmfish on 2018/8/7.
//  Copyright © 2018年 ash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASHSearchTagView : UIView
- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray;

@property(copy,nonatomic)void(^tagIndexAction)(NSInteger index);
@end
