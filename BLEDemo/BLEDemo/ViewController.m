//
//  ViewController.m
//  BLEDemo
//
//  Created by ZhaoHanjun on 16/4/3.
//  Copyright © 2016年 https://github.com/CoderHJZhao. All rights reserved.
//

#import "ViewController.h"
#import "HJCenterBLEViewController.h"
#import "HJPeripheralBLEViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)centralManager:(UIButton *)sender {
    [self.navigationController pushViewController:[[HJCenterBLEViewController alloc] init] animated:YES];
}

- (IBAction)peripheralManager:(UIButton *)sender {
    [self.navigationController pushViewController:[[HJPeripheralBLEViewController alloc] init] animated:YES];
}
@end
