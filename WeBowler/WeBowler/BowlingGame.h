//
//  BowlingGame.h
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BowlingGame : NSObject

@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) NSUInteger currentFrame;
@property (nonatomic, readonly) NSUInteger remainingPins;

@property (nonatomic, strong) NSArray *frames;


- (BOOL)rollBall:(NSUInteger)droppedPins;
- (NSUInteger)getScore;
- (NSString *)generateScoreboard;

@end
