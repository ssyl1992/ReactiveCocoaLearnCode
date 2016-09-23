//
//  LoginViewModel.h
//  RAC-MVVC实战Login
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
@class Account;

@interface LoginViewModel : NSObject
@property (nonatomic, strong) Account *account;


// 是否允许登录的信号

@property (nonatomic, strong ,readonly) RACSignal *enableLoginSignal;

@property (nonatomic, strong, readonly) RACCommand *loginCommand;

@end
