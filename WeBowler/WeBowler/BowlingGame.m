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
@property (nonatomic, readwrite) NSUInteger currentFrame;
@property (nonatomic, readwrite) NSUInteger remainingPins;


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
        self.currentFrame = 1;
        self.remainingPins = TOTAL_PINS;
    }
    return self;
}

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

    BowlingFrame *currFrame = (BowlingFrame *)self.frames[self.currentFrame - 1];

    if (self.currentFrame == NUM_FRAMES) {
        // Need special handling for the last frame
        if (!currFrame.finished) {
            [currFrame dropPins:droppedPins];
            if (currFrame.finished && currFrame.pendingBonus) {
                // First bonus ball
                self.remainingPins = TOTAL_PINS;
            } else {
                self.remainingPins = currFrame.remainingPins;
            }
        } else if (currFrame.pendingBonus) {
            // We just rolled the first bonus ball. Set the number of pins left for the second bonus ball.
            self.remainingPins = TOTAL_PINS - droppedPins;
            if (self.remainingPins == 0) {
                self.remainingPins = TOTAL_PINS;
            }
        }
        if (currFrame.finished && !currFrame.pendingBonus) {
            // End of game!
            self.finished = YES;
            self.remainingPins = 0;
            return YES;
        }
        return NO;
    }

    // Handling for the other frans
    [currFrame dropPins:droppedPins];
    if (currFrame.finished) {
        self.currentFrame++;
        self.remainingPins = TOTAL_PINS;
        return YES;
    }
    self.remainingPins = currFrame.remainingPins;
    return NO;
}

- (NSUInteger)getScore {
    NSUInteger score = 0;
    /*
    for (BowlingFrame *frame in self.frames) {
        score += [frame getScore];
    }
     */
    return score;
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
