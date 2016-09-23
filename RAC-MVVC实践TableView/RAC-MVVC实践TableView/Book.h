//
//  Book.h
//  RAC-MVVC实践TableView
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Book : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) UIImage *image;


- (instancetype) initWithDict:(NSDictionary *)dict ;

@end
