//
//  BaseLearningBlock.m
//  Review_OC
//
//  Created by berlin.li on 2022/8/2.
//

#import "BaseLearningBlock.h"

@implementation BaseLearningBlock

- (void)block_test_1 {
//    https://juejin.cn/post/6998778491906818055
//    https://juejin.cn/post/7002032670678974495
    // 一个是捕获变量+1，然后copy到堆上面+1，所以是3。
    NSObject *obj = [[NSObject alloc] init];
    
    NSLog(@"1.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    void(^myBlock)(void) = ^{
        NSLog(@"3.block中 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    };
    
    NSLog(@"2.block外 obj = %ld", CFGetRetainCount((__bridge  CFTypeRef)(obj)));
    
    myBlock();
}

@end
