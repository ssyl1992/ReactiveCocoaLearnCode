//
//  ViewController.m
//  RAC-MVVC实践TableView
//
//  Created by 滕跃兵 on 2016/9/23.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "ViewController.h"
#import "RequestModel.h"
#import "Book.h"
#import "MBProgressHUD+MJ.h"

@interface ViewController ()
@property (nonatomic, strong) RequestModel *requestViewModel;

@end

@implementation ViewController

- (RequestModel *)requestViewModel {
    if (_requestViewModel == nil) {
        _requestViewModel = [[RequestModel alloc] init];
    }
    return _requestViewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 100;
    [self bindModel];
}


- (void)bindModel {
    
    RACSignal *requesSiganl = [self.requestViewModel.command execute:nil];
    
    // 获取请求的数据
    [requesSiganl subscribeNext:^(NSArray *x) {
        
        self.requestViewModel.models = x;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
       
    }];
    
    
    [[self.requestViewModel.command.executing skip:1] subscribeNext:^(id x) {
        if ( [x isEqualToNumber:@(YES)]) {
            [MBProgressHUD showMessage:@"正在加载数据..." toView:self.view];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requestViewModel.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Book *book = self.requestViewModel.models[indexPath.row];
    cell.detailTextLabel.text = book.subTitle;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = book.title;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = book.image;
    return cell;
    
}
@end
