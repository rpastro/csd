//
//  ViewController.m
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "ViewController.h"
#import "BowlingGame.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pinsDroppedLabel;
@property (weak, nonatomic) IBOutlet UITextView *scoreBoardText;
@property (weak, nonatomic) IBOutlet UIButton *rollButton;
@property (strong, nonatomic) BowlingGame *game;

@end


@implementation ViewController

static const int SCORE_ENHANCER = 5; // Increases the chance for a higher score

- (BowlingGame *)game {
    if (!_game) {
        _game = [[BowlingGame alloc] init];
    }
    return _game;
}

- (IBAction)rollBall {
    if (self.game.finished) {
        return;
    }

    NSUInteger droppedPins = arc4random() % (self.game.remainingPins + 1);
    droppedPins += arc4random() % SCORE_ENHANCER;
    if (droppedPins > self.game.remainingPins) {
        droppedPins = self.game.remainingPins;
    }

    [self.game rollBall:droppedPins];
    self.pinsDroppedLabel.text = [NSString stringWithFormat:@"Dropped pins: %lu", droppedPins];
    self.scoreBoardText.text = [self.game generateScoreboard];
    if (self.game.finished) {
        self.rollButton.enabled = NO;
    }
}

- (IBAction)restartGame {
    self.game = [[BowlingGame alloc] init];
    self.pinsDroppedLabel.text = @"Dropped pins:";
    self.scoreBoardText.text = @"";
    self.rollButton.enabled = YES;
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
