//
//  ScoreViewController.m
//  WeBowler
//
//  Created by Phil Berger on 11/18/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "ScoreViewController.h"
#import "FrameCell.h"


@interface ScoreViewController()

@property (nonatomic, strong) NSArray *frames;

@end

@implementation ScoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.frames = self.game.frames;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    FrameCell *cell = [[FrameCell alloc] init];

    UILabel *firstRollScore = [[UILabel alloc] init];
    firstRollScore.text = @"0";

    UILabel *secondRollScore = [[UILabel alloc] init];
    secondRollScore.text = @"0";

    UILabel *totalScore = [[UILabel alloc] init];
    totalScore.text = @"0";

    [cell addSubview:firstRollScore];
    [cell addSubview:secondRollScore];
    [cell addSubview:totalScore];

    return cell;
}

- (IBAction)quit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
