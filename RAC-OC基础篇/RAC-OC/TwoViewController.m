//
//  TwoViewController.m
//  RAC-OC
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "TwoViewController.h"
#import "ReactiveCocoa.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"点击按钮" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 100);
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.subjectDelegate sendNext:btn.titleLabel.text];
        [self.subjectDelegate sendCompleted];
        
    }];
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
