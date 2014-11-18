//
//  BowlingFrame.h
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BowlingFrame : NSObject

@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) BOOL pendingBonus;

@property (nonatomic, readonly) NSUInteger remainingPins;

- (BOOL)isStrike;
- (BOOL)isSpare;

- (void)reset;

- (NSString *)firstBall;
- (NSString *)secondBall;
- (NSString *)firstBonusBall;
- (NSString *)secondBonusBall;

- (void)dropPins:(NSUInteger)droppedPins;
- (void)addBonusBall:(NSUInteger)droppedPins;

- (NSUInteger)getScore;

@end
