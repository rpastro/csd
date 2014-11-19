//
//  BowlingGame.m
//  score
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingGame.h"
#import "BowlingFrame.h"

@interface BowlingGame()

@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) NSUInteger currentFrameNumber;
@property (nonatomic, readwrite) NSUInteger lastPlayedFrameNumber;
@property (nonatomic, readwrite) NSUInteger remainingPins;
@property (nonatomic, strong, readwrite) NSString *lastBallScore;
@property (nonatomic, strong, readwrite) NSArray *frames;

@end

@implementation BowlingGame

static const NSUInteger NUM_FRAMES = 10;
static const NSUInteger TOTAL_PINS = 10;

- (NSArray *)frames {
    if (!_frames) {
        NSMutableArray *bowlingFrames = [[NSMutableArray alloc] init];
        for (int count = 0; count < NUM_FRAMES; count++) {
            [bowlingFrames addObject:[[BowlingFrame alloc] init]];
        }
        _frames = [bowlingFrames copy];
    }
    return _frames;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.finished = NO;
        self.currentFrameNumber = 1;
        self.lastPlayedFrameNumber = 1;
        self.remainingPins = TOTAL_PINS;
        self.lastBallScore = @"";
    }
    return self;
}

// rollBall returns YES whenever the rack needs to be reset
- (BOOL)rollBall:(NSUInteger)droppedPins {
    if (self.finished) {
        // The game is already finished.
        return YES;
    }

    if (droppedPins > self.remainingPins) {
        droppedPins = self.remainingPins;
    }

    // Start by adding the bonus (if any)
    for (BowlingFrame *frame in self.frames) {
        if (frame.pendingBonus) {
            [frame addBonusBall:droppedPins];
        }
    }

    self.lastPlayedFrameNumber = self.currentFrameNumber;
    // By default set the lastBallScore to the number of dropped pins.
    // This is overriden below in case of spares and strikes
    self.lastBallScore = [NSString stringWithFormat:@"%lu", droppedPins];

    BowlingFrame *currFrame = (BowlingFrame *)self.frames[self.currentFrameNumber - 1];

    if (self.currentFrameNumber == NUM_FRAMES) {
        // Need special handling for the last frame
        if (!currFrame.finished) {
            [currFrame dropPins:droppedPins];
            if (currFrame.finished && currFrame.pendingBonus) {
                // Prepare for the first bonus ball
                if ([currFrame isStrike]) {
                    self.lastBallScore = @"X";
                } else if ([currFrame isSpare]) {
                    self.lastBallScore = @"/";
                }
                self.remainingPins = TOTAL_PINS;
                return YES;
            } else {
                self.remainingPins = currFrame.remainingPins;
            }
        } else if (currFrame.pendingBonus) {
            // We just rolled the first bonus ball. Set the number of pins left for the second bonus ball.
            self.remainingPins = TOTAL_PINS - droppedPins;
            if (self.remainingPins == 0) {
                self.lastBallScore = @"X";
                self.remainingPins = TOTAL_PINS;
                return YES;
            }
        }
        if (currFrame.finished && !currFrame.pendingBonus) {
            // End of game!
            self.finished = YES;
            self.remainingPins = TOTAL_PINS;
            return YES;
        }
        return NO;
    }

    // Handling for the other frans
    [currFrame dropPins:droppedPins];
    if (currFrame.finished) {
        if ([currFrame isStrike]) {
            self.lastBallScore = @"X";
        } else if ([currFrame isSpare]) {
            self.lastBallScore = @"/";
        }
        self.currentFrameNumber++;
        self.remainingPins = TOTAL_PINS;
        return YES;
    }
    self.remainingPins = currFrame.remainingPins;
    return NO;
}

- (NSUInteger)getScore {
    NSUInteger score = 0;

    for (BowlingFrame *frame in self.frames) {
        score += [frame getScore];
    }

    return score;
}

- (BowlingFrame *)getCurrentFrame {
    return (BowlingFrame *)self.frames[self.currentFrameNumber - 1];
}

- (BowlingFrame *)getLastPlayedFrame {
    return (BowlingFrame *)self.frames[self.lastPlayedFrameNumber - 1];
}


- (NSString *)generateFrameScore:(NSUInteger)frameNr {
    BowlingFrame *frame = (BowlingFrame *)self.frames[frameNr - 1];
    if (!frame.started) {
        return @"";
    }
    if (frameNr == NUM_FRAMES) {
        // Tenth Frame
        if ([frame isStrike]) {
            return [NSString stringWithFormat:@"| %@ | %@ | %@ |", [frame firstBall], [frame firstBonusBall], [frame secondBonusBall]];
        } else if ([frame isSpare]) {
            return [NSString stringWithFormat:@"| %@ | %@ | %@ |", [frame firstBall], [frame secondBall], [frame firstBonusBall]];
        }
    }
    return [NSString stringWithFormat:@"| %@ | %@ |", [frame firstBall], [frame secondBall]];
}


- (NSString *)generateCurrentFrameScore {
    return [self generateFrameScore:self.currentFrameNumber];
}

- (NSString *)generateLastPlayedFrameScore {
    return [self generateFrameScore:self.lastPlayedFrameNumber];
}

- (NSString *)generateScoreboard {
    NSMutableString *score = [[NSMutableString alloc] init];
    for (NSUInteger frameNr = 1; frameNr <= [self.frames count]; frameNr++) {
        BowlingFrame *frame = (BowlingFrame *)self.frames[frameNr - 1];
        if (!frame.started) {
            break;
        }
        if (frameNr == NUM_FRAMES) {
            if ([frame isStrike]) {
                [score appendFormat:@"%lu) |%@|%@|%@|", frameNr, [frame firstBall], [frame firstBonusBall], [frame secondBonusBall]];
            } else if ([frame isSpare]) {
                [score appendFormat:@"%lu) |%@|%@|%@|", frameNr, [frame firstBall], [frame secondBall], [frame firstBonusBall]];
            } else {
                [score appendFormat:@"%lu) |%@|%@|  ", frameNr, [frame firstBall], [frame secondBall]];
            }
        } else {
            [score appendFormat:@"%lu)  |%@|%@|  ", frameNr, [frame firstBall], [frame secondBall]];
        }
        if (frame.finished && !frame.pendingBonus) {
            [score appendFormat:@"  Score = %lu", [frame getScore]];
        }
        [score appendString:@"\n"];
    }
    [score appendFormat:@"\nTotal Score = %lu", [self getScore]];
    return score;
}

@end
