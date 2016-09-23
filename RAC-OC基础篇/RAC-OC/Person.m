//
//  Person.m
//  RAC-OC
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
    
};
+ (instancetype)personWithDict:(NSDictionary *)dict {
    return [[Person alloc] initWithDict:dict];
}
@end
