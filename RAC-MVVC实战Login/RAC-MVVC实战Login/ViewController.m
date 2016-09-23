//
//  ViewController.m
//  RAC-MVVC实战Login
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "LoginViewModel.h"
#import "Account.h"
#import "MBProgressHUD+MJ.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) LoginViewModel *model;
@end

@implementation ViewController

- (LoginViewModel *)model {
    if (_model == nil) {
        _model = [[LoginViewModel alloc] init];
    }
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindModel];
    
}

- (void)bindModel {
    
    // 只要文本框改变就会给account赋值
    RAC(self.model.account,name) = _accountTextField.rac_textSignal;
    RAC(self.model.account,pwd) = _pwdTextField.rac_textSignal;
    
    // 绑定登录按钮
    RAC(self.loginBtn,enabled) = self.model.enableLoginSignal;
    
    // 监听登录按钮的点击
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        // 执行登录事件
        [self.model.loginCommand execute:nil];
    }];
    

    // 监听登录状态
    [[_model.loginCommand.executing skip:1] subscribeNext:^(id x) {
        if ([x isEqualToNumber:@(YES)]) {
            //            NSLog(@"正在登录");
            [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD hideHUD];
        }
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
