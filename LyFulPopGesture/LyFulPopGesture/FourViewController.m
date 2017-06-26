//
//  FourViewController.m
//  003
//
//  Created by 张杰 on 2017/6/24.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "FourViewController.h"

@interface FourViewController ()
- (IBAction)logOut:(id)sender;

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)logOut:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
