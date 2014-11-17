//
//  ViewController.m
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pinsDroppedLabel;
@property (weak, nonatomic) IBOutlet UITextView *scoreBoardText;

@end

@implementation ViewController

- (IBAction)rollBall {
    int droppedPins = (int)(arc4random() % 11);
    self.pinsDroppedLabel.text = [NSString stringWithFormat:@"Pins: %d", droppedPins];


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
