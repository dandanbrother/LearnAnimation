//
//  ElasticityView.m
//  LearnAnimation
//
//  Created by 倪丁凡 on 16/3/30.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import "ElasticityView.h"

@implementation ElasticityView {
    CGRect elasticityFrame;
    UIImageView *ballView;
    
    CAShapeLayer *shapeLayer;
    
    UIDynamicAnimator *animator;
    UICollisionBehavior *collision;
    UISnapBehavior *snap;
    
    BOOL isFirstTime;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self.userFrame = frame;
    elasticityFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + [UIScreen mainScreen].bounds.size.height);
    
    self = [super initWithFrame:elasticityFrame];
    if (self) {
        self.isLoading = NO;
        isFirstTime = NO;

        self.frame = elasticityFrame;
        
        //贝塞尔曲线控制点
        self.controlPoint = [[UIView alloc] initWithFrame:CGRectMake(self.userFrame.size.width / 2 - 5, self.userFrame.size.height - 5, 10, 10)];
        self.controlPoint.backgroundColor = [UIColor blueColor];
        [self addSubview:self.controlPoint];
        
        //小球视图
        ballView = [[UIImageView alloc] initWithFrame:CGRectMake(self.userFrame.size.width / 3 - 20, self.userFrame.size.height - 100, 40, 40)];
        ballView.image = [UIImage imageNamed:@"ball"];
        ballView.backgroundColor = [UIColor clearColor];
        [self addSubview:ballView];
        
        //UIDynamic
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[ballView]];
        gravity.magnitude = 2.0;
        [animator addBehavior:gravity];
        
        collision = [[UICollisionBehavior alloc] initWithItems:@[ballView]];
        
        UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
        item.elasticity = 0;
        item.density = 1;
        
        shapeLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:shapeLayer below:ballView.layer];
    }

    
    return self;
}



- (void)drawRect:(CGRect)rect {
    if (!self.isLoading) {
        [collision removeBoundaryWithIdentifier:@"弧形"];
    } else {
        if (!isFirstTime) {
            isFirstTime = YES;
            snap = [[UISnapBehavior alloc] initWithItem:ballView snapToPoint:CGPointMake(self.userFrame.size.width / 2, self.userFrame.size.height - (130 + 64.5)/2)];
            [animator addBehavior:snap];
            [self startLoading];
        }
    }
//    self.controlPoint.center = CGPointMake(self.userFrame.size.width/2,self.userFrame.size.height + self.controlPointOffset);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.userFrame.size.height)];
    [path addQuadCurveToPoint:CGPointMake(self.userFrame.size.width, self.userFrame.size.height) controlPoint:self.controlPoint.center];
    [path addLineToPoint:CGPointMake(self.userFrame.size.width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    
    if (!self.isLoading) {
        [collision addBoundaryWithIdentifier:@"弧形" forPath:path];
        [animator addBehavior:collision];
    }
}

- (void)startLoading {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2);
    rotationAnimation.duration = 0.9;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [ballView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
