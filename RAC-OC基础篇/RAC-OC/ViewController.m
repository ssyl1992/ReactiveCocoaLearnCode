//
//  ViewController.m
//  RAC-OC
//
//  Created by 滕跃兵 on 16/9/20.
//  Copyright © 2016年 tyb. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "NetworkSignal.h"
#import "TwoViewController.h"
#import "Person.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) RACCommand *command;
@property (weak, nonatomic) IBOutlet UIButton *redV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self others];
    
}




- (void)others {
    // 1.代替代理
    // 需求：自定义redView,监听红色view中按钮点击
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    [[self rac_signalForSelector:@selector(click:)] subscribeNext:^(id x) {
        NSLog(@"点击红色按钮");
        _redV.center = CGPointMake(100, 100);
    }];
    
    // 2.KVO
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    // observer:可以传入nil
    [[_redV rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // 3.监听事件
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSLog(@"按钮被点击了");
    }];
    
    // 4.代替通知
    // 把监听到的通知转换信号
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    // 5.监听文本框的文字改变
    [_textField.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"文字改变了%@",x);
    }];
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
    
    
}
// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
}
















// RACMulticastConnection

- (void)racMulticastConnection {
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
    // 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
    // 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
    // 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
    // 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
    // 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
    // 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
    // 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    // 1.创建请求信号
    //    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    //
    //
    //        NSLog(@"发送请求");
    //
    //        return nil;
    //    }];
    //    // 2.订阅信号
    //    [signal subscribeNext:^(id x) {
    //
    //        NSLog(@"接收数据");
    //
    //    }];
    //    // 2.订阅信号
    //    [signal subscribeNext:^(id x) {
    //
    //        NSLog(@"接收数据");
    //
    //    }];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者一信号");
        
    }];
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二信号");
        
    }];
    
    // 4.连接,激活信号
    [connect connect];
}


//RACCommand
- (void)raccommand {
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString * input) {
        //@"http://www.weather.com.cn/data/cityinfo/101010100.html"
        
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:input] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                // 发送数据
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                
                [subscriber sendNext:dict];
                [subscriber sendCompleted];
            }];
            
            [task resume];
            
            
            return nil;
        }];
        
        
        
    }];
    
    _command = command;
    
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id value) {
            NSLog(@"%@",value);
        }];
    }];
    
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id value) {
            NSLog(@"%@",value);
        }];
    }];
    
    
    
    
    [command execute:@"http://www.weather.com.cn/data/cityinfo/101010100.html"];
    
    
    
    
    
}



// RACTuple RACSequence
- (void)racsequence {
    
    // 遍历数组
    NSArray *numbers = @[@1,@2,@3,@4,@5,@6,@7,@8,@9];
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    
    // 遍历字典
    NSDictionary *dict = @{@"name":@"张三",
                           @"age":@18};
    
    //    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
    //        RACTupleUnpack(NSString *key, NSString *value) = x;
    //        NSLog(@"%@---%@",key,value);
    //
    //    }];
    
    
    NSDictionary *dict2 = @{@"name":@"李四",
                            @"age":@20};
    NSArray *dictArr = @[dict,dict2];
    
    NSMutableArray *items = [NSMutableArray array];
    
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        
        [items addObject:[Person personWithDict:x]];
        
    }];
    
    
    
    // 字典转模型
    NSArray *models = [[dictArr.rac_sequence map:^id(id value) {
        return [Person personWithDict:value];
    }] array];
    NSLog(@"---%@",models);
    
    for (Person *p in models) {
        NSLog(@"name:%@\tage:%@",p.name,p.age);
    }
    
    
    
}

- (IBAction)click:(id)sender {
}


// 使用RACSuject替换代理
- (void)subjectReplaceDelegate {
    
    
    RACSignal *signal = [self.btn rac_signalForControlEvents:UIControlEventTouchUpInside];
    
    
    [signal subscribeNext:^(id x) {
        TwoViewController *two = [[TwoViewController alloc] init];
        two.subjectDelegate = [RACSubject subject];
        [two.subjectDelegate subscribeNext:^(id x) {
            NSLog(@"点击了按钮 --- %@",x);
            self.label.text = x;
        }];
        
        
        [self presentViewController:two animated:YES completion:nil];
        
        
    }];
    
    
    RAC(self.textField,text) = RACObserve(self.label, text);
    
    
}

// RACReplaySubject
- (void)replaySubject {
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    
    
    
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    [subject sendNext:@"aaa"];
    [subject sendNext:@"bbb"];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    
    
    
    
}

// RACSUBJECT
- (void)subject {
    // RACSubject使用步骤
    // 1. 创建信号 [RACSubeject subject] 创建信号时没有block
    // 2. 订阅信号 必须先订阅
    // 3. 发送信号
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 订阅信号   ******必须先订阅
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者----%@",x);
    }];
    
    [subject subscribeCompleted:^{
        NSLog(@"订阅结束");
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者----%@",x);
    }];
    
    [subject sendNext:@"aaa"];
    [subject sendNext:@"bbb"];
    
    [subject sendCompleted];
    
    
}

// RAC网络请求
- (void)signalForNetworking {
    RACSignal *signal = [NetworkSignal signal];
    [signal subscribeNext:^(NSDictionary* x) {
        NSLog(@"hhhhhhhh%@",x);
    }];
    [signal subscribeNext:^(NSDictionary* x) {
        NSLog(@"hhhhhhhh%@",x);
    }];
    
    
}
//RAC宏的简单使用
- (void)RACMacro{
    
    
    // RACSignal使用步骤：
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 - (void)sendNext:(id)value
    
    //    RACSignal *signal =  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    //
    //        [subscriber sendNext:@"next"];
    //
    //        return [RACDisposable disposableWithBlock:^{
    //            NSLog(@"信号被销毁");
    //        }];
    //    }];
    //
    //    [signal subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    }];
    
    RAC(self.label,text) = self.textField.rac_textSignal;
    
    RAC(self.btn,enabled) = [self.textField.rac_textSignal map:^id(NSString * value) {
        NSLog(@"%@",value);
        return [value isEqualToString:@"123"]?@1:@0;
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
