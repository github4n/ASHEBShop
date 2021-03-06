//
//  ASHTabManager.m
//  ASHEBShop
//
//  Created by xmfish on 2018/8/1.
//  Copyright © 2018年 ash. All rights reserved.
//

#import "ASHTabManager.h"
#import "ASHTabViewModel.h"
@interface ASHTabManager()
@property(nonatomic, strong)ASHTabViewModel* viewModel;
@property(nonatomic,strong)ASHTabModel* model;
@property(nonatomic,strong)ASHTabModel* zhekouModel;
@end
@implementation ASHTabManager
+ (void)load
{
    [ASHTabManager shareInstance];
}
+ (instancetype)shareInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _viewModel = [ASHTabViewModel new];
        @weakify(self);
        [_viewModel.requestFinishedSignal subscribeNext:^(ASHTabViewModel* tabViewModel) {
            @strongify(self);
            
            if (tabViewModel.model) {
                self.model = tabViewModel.model;
            }
            if (tabViewModel.zhekouModel) {
                self.zhekouModel = tabViewModel.zhekouModel;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kASH_Post_Tab" object:nil];
        }];
        [_viewModel requestData];
    }
    return self;
}
@end
