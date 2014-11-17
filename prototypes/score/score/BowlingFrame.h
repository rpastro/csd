//
//  BowlingFrame.h
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BowlingFrame : NSObject

@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) int firstBall;
@property (nonatomic, readonly) int secondBall;
@property (nonatomic, readonly) NSUInteger remainingPins;

@property (nonatomic) NSUInteger firstBonusBall;
@property (nonatomic) NSUInteger secondBonusBall;

- (BOOL)isStrike;
- (BOOL)isSpare;

- (void)reset;
- (void)dropPins:(NSUInteger)droppedPins;
- (NSUInteger)getScore;

@end
