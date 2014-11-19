//
//  BowlingPinView.m
//  animation
//
//  Created by Unify Inc on 11/18/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingPinView.h"

@implementation BowlingPinView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [circle addClip];

    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);

    [[UIColor blackColor] setStroke];
    [circle setLineWidth:5.0];
    [circle stroke];

    CGRect innerRect = CGRectInset(self.bounds, self.bounds.size.width * 0.2, self.bounds.size.height * 0.2);
    UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:innerRect];
    [[UIColor redColor] setStroke];
    [innerCircle setLineWidth:3.0];
    [innerCircle stroke];
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
