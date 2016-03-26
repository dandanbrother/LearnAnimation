//
//  GestureView.m
//  LearnAnimation
//
//  Created by 倪丁凡 on 16/3/26.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import "GestureView.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface GestureView ()
@property (nonatomic, strong) UIView *dot;  //用来辅助测量路径
@property (nonatomic, assign) CGFloat dotX;
@property (nonatomic, assign) CGFloat dotY;
@property (nonatomic, strong) CAShapeLayer *dotShapeLayer; //拖拽时的曲面


@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) CADisplayLink *disPlayLink;//计算画面的更新，动画过程的演变

@end

@implementation GestureView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.4;
        [self addGestureandDisPlayLink];
        [self initDotView];
        [self initShapeLayer];
        [self updateShapeLayerPath];
    }
    return self;
}

/**
 *  添加手势和DisPlayLink
 */
- (void)addGestureandDisPlayLink {
    _isAnimating = NO;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:pan];
    
    _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _disPlayLink.paused = YES;
}

/**
 *  初始化shaperLayer
 */
- (void)initShapeLayer {
    self.dotShapeLayer = [CAShapeLayer layer];
    self.dotShapeLayer.fillColor = [UIColor yellowColor].CGColor;
    [self.layer addSublayer:self.dotShapeLayer];
}

/**
 *  初始化dotView
 */
- (void)initDotView {
    self.dot = [[UIView alloc] initWithFrame:CGRectMake(WIDTH/2, 0, 3, 3)];
    self.dot.backgroundColor = [UIColor redColor];
    [self addSubview:self.dot];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)recoginzer {
    if (!_isAnimating) {
        if (recoginzer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentPoint = [recoginzer translationInView:self];
            
            //currentPoint 以self的左上角为起点,所以_dot.x要加半个屏幕的宽度，才能在中点
            _dotX = WIDTH / 2 + currentPoint.x;
            _dotY = currentPoint.y * 0.7;
            _dot.frame = CGRectMake(_dotX, _dotY, _dot.frame.size.width, _dot.frame.size.height);
            [self updateShapeLayerPath];
            
        }
        else if (recoginzer.state == UIGestureRecognizerStateCancelled ||
                 recoginzer.state == UIGestureRecognizerStateEnded ||
                 recoginzer.state == UIGestureRecognizerStateFailed)
        {
            // 手势结束时,_shapeLayer返回原状并产生弹簧动效
            _isAnimating = YES;
            _disPlayLink.paused = NO; //开启DisplayLink 执行calculatePath方法
            [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _dot.frame = CGRectMake(WIDTH / 2, 0, 3, 3);
            } completion:^(BOOL finished) {
                if (finished) {
                    _disPlayLink.paused = YES;
                    _isAnimating = NO;
                }
            }];
            
        }
    }
}

- (void)updateShapeLayerPath {
    //画曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)]; //endPoint
    [path addLineToPoint:CGPointMake(WIDTH, 0)];
    [path addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:CGPointMake(_dotX, _dotY)];
    [path closePath];
    _dotShapeLayer.path = path.CGPath;
}

/**
 *  当手势执行结束，根据_dot的坐标，更新_dotShapeLayer的形状，完成回弹动画
 */
- (void)calculatePath {
    CALayer *dotLayer = _dot.layer.presentationLayer;
    _dotX = dotLayer.position.x;
    _dotY = dotLayer.position.y;
    [self updateShapeLayerPath];
}
@end
