//
//  HomeTableViewController.m
//  LearnAnimation
//
//  Created by 倪丁凡 on 16/3/28.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#define ElasticHeaderHeight 300

#import "HomeTableViewController.h"
#import "ElasticityView.h"


@interface HomeTableViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) ElasticityView *refreshView;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation HomeTableViewController

#pragma mark - 懒加载
- (NSMutableArray *)array{
    if (!_array) {
        self.array = [[NSMutableArray alloc] initWithObjects:@"吃啥",@"喝啥",@"想吃啥",@"想喝啥", nil];
    }
    return _array;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title  = @"弹性小球下拉刷新";
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:pan];
    
    pan.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handlePanAction:(UIGestureRecognizer *)recognizer {
    if (!self.refreshView.isLoading) {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentPoint = [recognizer locationInView:self.refreshView];
            
            self.refreshView.controlPoint.frame = CGRectMake(currentPoint.x, currentPoint.y, self.refreshView.controlPoint.frame.size.width, self.refreshView.controlPoint.frame.size.height);
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.array[indexPath.row];
    
    return cell;
    
}

//判断向上滑还是想下滑     初始化时会先调用一次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y > -64.5) {
        if (self.refreshView.isLoading == NO) {
            //向下滑但没到刷新的距离
            [self.refreshView removeFromSuperview];
            self.refreshView = nil;
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        return ;
    }
    
    if ((scrollView.contentOffset.y < -64.5) && self.displayLink == nil) {
        self.refreshView = [[ElasticityView alloc] initWithFrame:CGRectMake(0, -ElasticHeaderHeight, [UIScreen mainScreen].bounds.size.width, ElasticHeaderHeight)];
        self.refreshView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:self.refreshView aboveSubview:self.tableView];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else if ((-scrollView.contentOffset.y - 64.5) < 0){
        NSLog(@"...");
        [self.refreshView removeFromSuperview];
        self.refreshView = nil;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

//松手时
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offset = -scrollView.contentOffset.y - 64.5;
    if (offset >= 130) {
        self.refreshView.isLoading = YES;
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.refreshView.controlPoint.center = CGPointMake(self.refreshView.userFrame.size.width / 2 , ElasticHeaderHeight);
            NSLog(@"control point center : %@",NSStringFromCGPoint(self.refreshView.controlPoint.center));
            self.tableView.contentInset = UIEdgeInsetsMake(130+64.5, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self performSelector:@selector(backToTop) withObject:nil afterDelay:2.0];
            
        }];
    }
}

//动画结束 删除一切
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.refreshView.isLoading == NO) {
        [self.refreshView removeFromSuperview];
        self.refreshView = nil;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

//松手后弹回顶部
- (void)backToTop {
    [self.refreshView.layer removeAnimationForKey:@"rotationAnimation"];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(64.5, 0, 0, 0);
    } completion:^(BOOL finished) {
        
        self.refreshView.isLoading = NO;
        [self.refreshView removeFromSuperview];
        self.refreshView = nil;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }];
    [self.array addObject:@"加载出来的"];
    [self.tableView reloadData];
}

//持续刷新屏幕的计时器
- (void)displayLinkAction:(CADisplayLink *)displayLink {
    self.refreshView.controlPointOffset = (self.refreshView.isLoading == NO)?(-self.tableView.contentOffset.y - 64.5) : (self.refreshView.controlPoint.layer.position.y - self.refreshView.userFrame.size.height);
    [self.refreshView setNeedsDisplay];
}
@end
