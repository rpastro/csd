//
//  BowlingFrame.m
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingFrame.h"

@interface BowlingFrame()

@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) int firstBall;
@property (nonatomic, readwrite) int secondBall;
@property (nonatomic, readwrite) NSUInteger remainingPins;

@end

@implementation BowlingFrame

static const NSUInteger TOTAL_PINS = 10;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)setFirstBonusBall:(NSUInteger)firstBonusBall {
    if ([self isSpare] || [self isStrike]) {
        if (firstBonusBall > TOTAL_PINS) {
            firstBonusBall = TOTAL_PINS;
        }
        _firstBonusBall = firstBonusBall;
    }
}

- (void)setSecondBonusBall:(NSUInteger)secondBonusBall {
    if ([self isStrike]) {
        if (secondBonusBall > TOTAL_PINS) {
            secondBonusBall = TOTAL_PINS;
        }
        _secondBonusBall = secondBonusBall;
    }
}

- (BOOL)isStrike {
    return (self.firstBall == TOTAL_PINS);
}

- (BOOL)isSpare {
    return (self.remainingPins == 0 && ![self isStrike]);
}

- (void)reset {
    self.finished = NO;
    self.firstBall = -1;
    self.secondBall = -1;
    self.remainingPins = TOTAL_PINS;
    self.firstBonusBall = 0;
    self.secondBonusBall = 0;
}

- (void)dropPins:(NSUInteger)droppedPins {
    if (self.finished) {
        // This frame is already over
        return;
    }
    if (droppedPins > self.remainingPins) {
        // Cannot drop more pins than available
        droppedPins = self.remainingPins;
    }
    if (self.firstBall < 0) {
        self.firstBall = (int)droppedPins;
        if (droppedPins == TOTAL_PINS) {
            self.secondBall = 0;
            self.finished = YES;
        }
    } else {
        self.secondBall = (int)droppedPins;
        self.finished = YES;
    }
    self.remainingPins -= droppedPins;
}

- (NSUInteger)getScore {
    NSUInteger score = 0;
    if (self.finished) {
        score = self.firstBall + self.secondBall;
        if ([self isStrike]) {
            score += self.firstBonusBall + self.secondBonusBall;
        } else if ([self isSpare]) {
            score += self.firstBonusBall;
        }
    }
    return score;
}

@end
