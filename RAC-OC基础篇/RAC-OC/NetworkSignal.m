//
//  NetworkSignal.m
//  RAC-OC
//
//  Created by 滕跃兵 on 2016/9/21.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "NetworkSignal.h"
#import "ReactiveCocoa.h"

@implementation NetworkSignal


+ (instancetype)signal {
    
    NetworkSignal *signal = (NetworkSignal *)[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

    NSLog(@"请求数据");
        
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"http://www.weather.com.cn/data/cityinfo/101010100.html"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//                NSLog(@"%@",dict);
                [subscriber sendNext:dict];
                [subscriber sendCompleted];
                
            }
            if (error) {
                [subscriber sendError:error];
            }
            
        }];
        
        
        [task resume];
        
       
        
        return  [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁结束");
        }];
        
        
        
    }];
    
    RACMulticastConnection *connect = [signal publish];
    [connect connect];
    
    
    
    return signal;
    
}
@end
