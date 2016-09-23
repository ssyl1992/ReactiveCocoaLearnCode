//
//  RequestModel.h
//  RAC-MVVC实践TableView
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"


@interface RequestModel : NSObject

@property (nonatomic, strong, readonly) RACCommand *command;

@property (nonatomic, strong) NSArray *models;

@property (nonatomic, strong, readonly) RACSignal *imageSignal;


@end
