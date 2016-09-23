//
//  LoginViewModel.m
//  RAC-MVVC实战Login
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "LoginViewModel.h"
#import "Account.h"
#import "MBProgressHUD+MJ.h"

@implementation LoginViewModel

- (Account *)account {
    if (_account == nil) {
        _account = [[Account alloc] init];
    }
    
    return _account;
}
- (instancetype)init {
    if (self = [super init]) {
        [self initialBind];
    }
    return self;
}

- (void)initialBind {
    // 监听账号的属性值是否改变，聚合成一个信号
    _enableLoginSignal = [RACSignal combineLatest:@[RACObserve(self.account, name),RACObserve(self.account, pwd)] reduce:^id(NSString *name,NSString *pwd){
        return @(name.length && pwd.length);
    }];
    
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"开始登录");
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           // 模仿登录延迟
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [subscriber sendNext:@"登录成功"];
                [subscriber sendCompleted];
            });
     
            return nil;
        }];
        
    }];
    
    [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        if ([x isEqualToString:@"登录成功"]) {
            NSLog(@"%@",x);
            
        }
    }];
 
    
}

@end
