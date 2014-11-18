//
//  ViewController.m
//  animation
//
//  Created by Unify Inc on 11/18/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingViewController.h"
#import "BallView.h"

@interface BowlingViewController () <UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *gameView;

@property (strong, nonatomic) BallView* ballView;
@property (strong, nonatomic) NSMutableArray* pinViews;
@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collider;
@property (strong, nonatomic) UIDynamicItemBehavior *animationOptions;

@property (nonatomic) CGFloat validPanGesture;
@property (nonatomic) CGFloat lastPositionX;
@property (nonatomic) BOOL ballInProgress;

@end

@implementation BowlingViewController

static const int NUM_PINS = 10;

static const NSString *LEFT_BOUNDARY_ID = @"LEFT";
static const NSString *RIGHT_BOUNDARY_ID = @"RIGHT";

static const CGFloat GESTURE_TO_SPEED_FACTOR = 10;

static const CGFloat LINE_OFFSET = 150.0;  // Distance from bottom to the foul line
static const CGFloat BALL_OFFSET = 100.0;  // Distance from bottom to origin for starting ball position
static const CGFloat BALL_WIDTH = 50.0;    // The bowling ball's width
static const CGFloat PIN_WIDTH = 20.0;     // The bowling pin's width


#pragma mark - Properties

- (NSMutableArray *)pinViews {
    if (!_pinViews) {
        _pinViews = [[NSMutableArray alloc] init];
    }
    return _pinViews;
}

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];
        _animator.delegate = self;
    }
    return _animator;
}

- (UICollisionBehavior *)collider {
    if (!_collider) {
        _collider = [[UICollisionBehavior alloc] init];
        [self.animator addBehavior:_collider];
    }
    return _collider;
}

- (UIDynamicItemBehavior *)animationOptions {
    if (!_animationOptions) {
        _animationOptions = [[UIDynamicItemBehavior alloc] init];
        [self.animator addBehavior:_animationOptions];
    }
    return _animationOptions;
}


#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {

}

#pragma mark - Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create ball
    CGRect ballFrame = CGRectMake(0, 0, BALL_WIDTH, BALL_WIDTH);
    self.ballView = [[BallView alloc] initWithFrame:ballFrame];

    // Create pins
    for (int count = 0; count < NUM_PINS; count++) {
        CGRect ballFrame = CGRectMake(0, 0, PIN_WIDTH, PIN_WIDTH);
        [self.pinViews addObject:[[BallView alloc] initWithFrame:ballFrame]];
    }

    // Create foul line
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Position ball and add it to the view
    [self positionBowlingBall];
    [self.gameView addSubview:self.ballView];
    [self.animationOptions addItem:self.ballView];
    [self.collider addItem:self.ballView];

    // Position pins and add it to the view
    [self positionPins];
    for (BallView *pinView in self.pinViews) {
        [self.gameView addSubview:pinView];
        [self.animationOptions addItem:pinView];
        [self.collider addItem:pinView];
    }

    // Add collider boundaries
    [self addColliderBoundaries];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Remove ball from view
    [self.ballView removeFromSuperview];
    [self.animationOptions removeItem:self.ballView];
    [self.collider removeItem:self.ballView];

    // Remove pins from view
    for (BallView *pinView in self.pinViews) {
        [pinView removeFromSuperview];
        [self.animationOptions removeItem:pinView];
        [self.collider removeItem:pinView];
    }

    // Remove collider boundaries
    //[self.collider removeAllBoundaries];
}

#pragma mark - Internal Functions

- (void)addColliderBoundaries {
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:CGPointMake(0, 0)];
    [leftPath addLineToPoint:CGPointMake(0, self.gameView.bounds.size.height)];
    [self.collider addBoundaryWithIdentifier:LEFT_BOUNDARY_ID forPath:leftPath];

    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:CGPointMake(self.gameView.bounds.size.width, 0)];
    [rightPath addLineToPoint:CGPointMake(self.gameView.bounds.size.width, self.gameView.bounds.size.height)];
    [self.collider addBoundaryWithIdentifier:RIGHT_BOUNDARY_ID forPath:rightPath];
}

- (void)positionBowlingBall {
    CGRect ballFrame;
    ballFrame.origin = CGPointMake((self.gameView.bounds.size.width - BALL_WIDTH) / 2,
                               self.gameView.bounds.size.height - BALL_OFFSET);
    ballFrame.size = CGSizeMake(BALL_WIDTH, BALL_WIDTH);
    self.ballView = [[BallView alloc] initWithFrame:ballFrame];
    [self.gameView addSubview:self.ballView];

    [self.animationOptions addItem:self.ballView];
    [self.collider addItem:self.ballView];
}

- (void)positionPins {
}


#pragma mark - Gestures

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint gesturePoint = [gesture locationInView:self.gameView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.validPanGesture = (gesturePoint.y > self.gameView.bounds.size.height - LINE_OFFSET);
            self.lastPositionX = gesturePoint.x;
            break;
        case UIGestureRecognizerStateChanged:
            if (self.validPanGesture) {
                if (gesturePoint.y < self.gameView.bounds.size.height - LINE_OFFSET) {
                    // User crossed the foul line. Release the ball.
                    CGPoint velocity = [gesture velocityInView:self.gameView];
                    velocity.x /= GESTURE_TO_SPEED_FACTOR;
                    velocity.y /= GESTURE_TO_SPEED_FACTOR;
                    [self.animationOptions addLinearVelocity:velocity
                                                     forItem:self.ballView];
                } else {
                    // Move the ball horizontally depending on position change
                    CGFloat delta = gesturePoint.x - self.lastPositionX;
                    if (delta < 0) {
                        // Move left
                        if (self.ballView.frame.origin.x + delta < 0) {
                            delta = -self.ballView.frame.origin.x;
                        }
                    } else {
                        // Move right
                        if (self.ballView.frame.origin.x + delta + BALL_WIDTH > self.gameView.bounds.size.width) {
                            delta = self.gameView.bounds.size.width - self.ballView.bounds.origin.x - BALL_WIDTH;
                        }
                    }
                    CGAffineTransformTranslate(self.ballView.transform, delta, 0);
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            self.validPanGesture = NO;
            break;
        default:
            // do nothing
            break;
    }
}

@end
