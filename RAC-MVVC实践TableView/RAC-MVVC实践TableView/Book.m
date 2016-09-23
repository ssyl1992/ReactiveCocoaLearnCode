//
//  Book.m
//  RAC-MVVC实践TableView
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "Book.h"
#import "ReactiveCocoa.h"

@implementation Book
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
      
        self.title = dict[@"title"];
        self.subTitle = dict[@"subtitle"];
        self.imageUrl = dict[@"image"];
        RAC(self,image) = [RACObserve(self, imageUrl) map:^id(id value) {
            return [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:value]]];
        }];
    }
    
    return self;
}
@end
