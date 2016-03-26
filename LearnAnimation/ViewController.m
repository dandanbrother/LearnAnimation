//
//  ViewController.m
//  LearnAnimation
//
//  Created by 倪丁凡 on 16/3/26.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import "ViewController.h"
#import "GestureView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GestureView *gestureView = [[GestureView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:gestureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
