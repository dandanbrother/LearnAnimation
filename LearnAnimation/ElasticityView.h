//
//  ElasticityView.h
//  LearnAnimation
//
//  Created by 倪丁凡 on 16/3/30.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElasticityView : UIView
@property (nonatomic, assign) CGFloat controlPointOffset;
@property (nonatomic, strong) UIView *controlPoint;
@property (nonatomic, assign) CGRect userFrame;

@property (nonatomic, assign) CGFloat controlPointX;
@property (nonatomic, assign) CGFloat controlPointY;


@property (nonatomic, assign) BOOL isLoading;
@end
