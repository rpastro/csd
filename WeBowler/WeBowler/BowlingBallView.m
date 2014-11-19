//
//  BallView.m
//  animation
//
//  Created by Unify Inc on 11/18/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingBallView.h"

@implementation BowlingBallView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [circle addClip];

    [[UIColor blackColor] setFill];
    UIRectFill(self.bounds);

    [[UIColor blackColor] setStroke];
    [circle stroke];
}

#pragma mark - Initialization
- (void)setup {
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

@end
