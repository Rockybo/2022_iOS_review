//
//  Interview01.m
//  Review_OC
//
//  Created by zhouxiangqun on 2022/8/6.
//

//  携程面试题
#import "Interview01.h"

@interface TestObject1 : NSObject
@property (nonatomic, strong) NSString *name;
@end

@implementation TestObject1
@end


@interface Interview01 ()

@property (nonatomic, strong) NSString *strongStr;
@property (nonatomic, copy) NSString *cpyStr;
@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) NSMutableArray *arrM;
@end

@implementation Interview01


- (void)l1_test1 {
    NSString *tmp = [NSString stringWithFormat:@"aaa"];
    self.strongStr = tmp;
    self.cpyStr = tmp;
    
    tmp = [NSString stringWithFormat:@"bbb"];
    
    NSLog(@"strongstr is %@", self.strongStr);
    NSLog(@"cpyStr is %@", self.cpyStr);
    
}

- (void)l1_test2 {
    NSMutableString *tmp = [NSMutableString stringWithFormat:@"aaa"];
    self.strongStr = tmp;
    self.cpyStr = tmp; // 这里应该用到了浅拷贝，指针拷贝
    
    [tmp setString:@"bbb"];
    
    NSLog(@"strongstr is %@", self.strongStr);
    NSLog(@"cpyStr is %@", self.cpyStr);
    
}

- (void)l1_test3 {
    NSMutableString *tmp = [NSMutableString stringWithFormat:@"aaa"];
    _strongStr = tmp;
    _cpyStr = tmp;
    
    [tmp setString:@"bbb"];
    
    NSLog(@"strongstr is %@", self.strongStr);
    NSLog(@"cpyStr is %@", self.cpyStr);
    
}

#pragma mark block

- (void)blocktest_1 {
//    https://juejin.cn/post/6998778491906818055   这个
//    https://juejin.cn/post/7002032670678974495
    
    NSObject *obj = [[NSObject alloc] init];
    
    NSLog(@"1.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    void(^myBlock)(void) = ^{
        NSLog(@"3.block中 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    };
    
    NSLog(@"2.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
     
    myBlock();
    
    // 133
}

- (void)blocktest_2 {
    NSObject *obj = [[NSObject alloc] init];
    
    NSLog(@"1.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    ^{
        NSLog(@"3.block中 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    }();
    
    NSLog(@"2.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
}

- (void)blocktest_3 {
    __block NSObject *obj = [[NSObject alloc] init];
    
    NSLog(@"1.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    void(^myBlock)(void) = ^{
        NSLog(@"3.block中 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    };
    
    NSLog(@"2.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    myBlock();
}

#pragma mark performSelector
- (void)l2_test1 {
    dispatch_queue_t queue = dispatch_queue_create("l2_test1", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"1");
        
        [self performSelector:@selector(log:) withObject:@"4" afterDelay:3.0];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            NSLog(@"3");
        }];
        NSLog(@"2");
    });
}

- (void)l2_test2 {
    self.thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
    }];
    
    [self.thread start];
    
    [self performSelector:@selector(log:) onThread:self.thread withObject:@"3" waitUntilDone:YES];
    NSLog(@"2");
}

- (void)log:(NSString *)value {
    NSLog(@"%@", value);
}

#pragma mark thread
- (void)test1 {
    self.arrM = [NSMutableArray array];
    for (int i = 0; i < 10000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.arrM addObject:[NSObject new]];
        });
    }
}

- (void)test2 {
    self.arrM = [NSMutableArray arrayWithCapacity:10000];
    for (int i = 0; i < 10000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.arrM addObject:[NSObject new]];
        });
    }
}

- (void)test3 {
    self.arrM = [NSMutableArray array];
    for (int i = 0; i < 10000; i++) {
        @synchronized (self) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.arrM addObject:[NSObject new]];
            });
        }
    }
}

- (void)test4 {
    self.arrM = [NSMutableArray array];
    for (int i = 0; i < 10000; i++) {
        @synchronized (self) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @synchronized (self) {
                    [self.arrM addObject:[NSObject new]];
                }
            });
        }
    }
}

- (void)test5 {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        TestObject1 *object = [TestObject1 new];
        object.name = [NSString stringWithFormat:@"logan%d", i];
        [dictM setValue:object forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 1000000; i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                TestObject1 *object = [dictM objectForKey:[NSString stringWithFormat:@"%d", arc4random() % 10]];
                NSLog(@"object name is %@", object.name);
            });
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100; i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int index = arc4random() % 10;
                TestObject1 *object = [TestObject1 new];
                object.name = [NSString stringWithFormat:@"fadfafdalfadlfdakfjalfdjalfdjalfj=%i", index];
                [dictM setValue:object forKey:[NSString stringWithFormat:@"%d", index]];
            });
        }
    });
}

@end

@end
