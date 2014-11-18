//
//  ViewController.m
//  WeBowler
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
