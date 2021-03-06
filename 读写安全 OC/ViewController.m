//
//  ViewController.m
//  读写安全 OC
//
//  Created by liuyaozong on 2022/1/24.
//

#import "ViewController.h"
#import <pthread.h>
@interface ViewController ()
@property (nonatomic,strong)  dispatch_queue_t queue;
@property (assign,nonatomic) pthread_rwlock_t lock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.queue = dispatch_queue_create("test_wf", DISPATCH_QUEUE_CONCURRENT);
    //初始化读写锁
    pthread_rwlock_init(&_lock, NULL);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self gcdBarrierAction];
}
//读写锁 来实现
-(void)lockAction {
    for (int i = 0; i < 10; i ++) {
        dispatch_async(self.queue, ^{
            [[[NSThread  alloc] initWithTarget:self selector:@selector(write) object:nil] start];
        });
        dispatch_async(self.queue, ^{
            [[[NSThread  alloc] initWithTarget:self selector:@selector(read) object:nil] start];
        });
    }
}

//GCD栅栏实现
-(void)gcdBarrierAction {
    for (int i = 0; i < 10; i ++) {
        dispatch_async(self.queue, ^{
            [[[NSThread  alloc] initWithTarget:self selector:@selector(write2) object:nil] start];
        });
        dispatch_async(self.queue, ^{
            [[[NSThread  alloc] initWithTarget:self selector:@selector(read2) object:nil] start];
        });
    }
}

//写数据
-(void)write {
    pthread_rwlock_wrlock(&_lock);
    sleep(1);
    NSLog(@"write");
    pthread_rwlock_unlock(&_lock);

}
//读数据
-(void)read {
    pthread_rwlock_rdlock(&_lock);
    sleep(1);
    NSLog(@"read");
    pthread_rwlock_unlock(&_lock);
}

//写数据
-(void)write2 {
    dispatch_barrier_async(self.queue, ^{
        sleep(1);
        NSLog(@"write");
    });
}
//读数据
-(void)read2 {
    dispatch_async(self.queue, ^{
        sleep(1);
        NSLog(@"read");
    });
}

-(void)dealloc {
    pthread_rwlock_destroy(&_lock);
}


@end
