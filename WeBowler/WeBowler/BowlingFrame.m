//
//  BowlingFrame.m
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingFrame.h"

@interface BowlingFrame()

@property (nonatomic, readwrite) BOOL started;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL pendingBonus;

@property (nonatomic, readwrite) NSUInteger remainingPins;

@property (nonatomic) int first;
@property (nonatomic) int second;
@property (nonatomic) int firstBonus;
@property (nonatomic) int secondBonus;

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

- (BOOL)isStrike {
    return (self.first == TOTAL_PINS);
}

- (BOOL)isSpare {
    return (self.remainingPins == 0 && ![self isStrike]);
}

- (void)reset {
    self.started = NO;
    self.finished = NO;
    self.pendingBonus = NO;
    self.remainingPins = TOTAL_PINS;
    self.first = -1;
    self.second = -1;
    self.firstBonus = -1;
    self.secondBonus = -1;
}

- (NSString *)convertToString:(int)pins {
    if (pins < 0) {
        return @" ";
    }
    if (pins == TOTAL_PINS) {
        return @"X";
    }
    return [[NSString alloc] initWithFormat:@"%d", pins];
}

- (NSString *)firstBall {
    return [self convertToString:self.first];
}

- (NSString *)secondBall {
    if ([self isStrike]) {
        return @" ";
    }
    if ([self isSpare]) {
        return @"/";
    }
    return [self convertToString:self.second];
}

- (NSString *)firstBonusBall {
    return [self convertToString:self.firstBonus];
}

- (NSString *)secondBonusBall {
    return [self convertToString:self.secondBonus];
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
    if (!self.started) {
        self.started = YES;
        self.first = (int)droppedPins;
        if (droppedPins == TOTAL_PINS) {
            self.second = 0;
            self.finished = YES;
        }
    } else {
        self.second = (int)droppedPins;
        self.finished = YES;
    }
    self.remainingPins -= droppedPins;
    if ([self isStrike] || [self isSpare]) {
        self.pendingBonus = YES;
    }
}

- (void)addBonusBall:(NSUInteger)droppedPins {
    if (self.pendingBonus) {
        if (droppedPins > TOTAL_PINS) {
            droppedPins = TOTAL_PINS;
        }
        if (self.firstBonus < 0) {
            self.firstBonus = (int)droppedPins;
            if ([self isSpare]) {
                self.pendingBonus = NO;
            }
        } else {
            self.secondBonus = (int)droppedPins;
            self.pendingBonus = NO;
        }
    }
}

- (NSUInteger)getScore {
    NSUInteger score = 0;
    if (self.started) {
        score = self.first;
        if (self.second >= 0) {
            score += self.second;
            if (self.firstBonus >= 0) {
                score += self.firstBonus;
                if (self.secondBonus >= 0) {
                    score += self.secondBonus;
                }
            }
        }
    }
    return score;
}

@end
