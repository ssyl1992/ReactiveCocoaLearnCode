//
//  TwoViewController.h
//  RAC-OC
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RACSubject;
@interface TwoViewController : UIViewController


@property (nonatomic, strong) RACSubject *subjectDelegate;

@end
