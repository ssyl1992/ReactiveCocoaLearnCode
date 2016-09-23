//
//  RequestModel.m
//  RAC-MVVC实践TableView
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "RequestModel.h"
#import "Book.h"

@implementation RequestModel

- (instancetype)init {
    if (self = [super init]) {
        [self initialBind];
    }
    return self;
}

- (void)initialBind {
    
    _command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           
            NSURLSession *session = [NSURLSession sharedSession];
            NSString *str = @"https://api.douban.com/v2/book/search?q=基础";
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:str];
            str = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
            
            
            NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    NSLog(@"%@",dict);
                    [subscriber sendNext:dict];
                    [subscriber sendCompleted];
                }
                if (error) {
                    NSLog(@"error:%@",error);
                }
  
               
            }];
            
            [task resume];
            
            return nil;
        }];

        return [signal map:^id(id value) {
            NSMutableArray *dictArr = value[@"books"];
            NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {
               return [[Book alloc] initWithDict:value];
           }] array];
            
            return modelArr;
        }];
    }];
    


}

@end
