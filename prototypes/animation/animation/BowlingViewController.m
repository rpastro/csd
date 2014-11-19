//
//  ViewController.m
//  animation
//
//  Created by Unify Inc on 11/18/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "BowlingViewController.h"
#import "BowlingBallView.h"
#import "BowlingPinView.h"

@interface BowlingViewController ()

@property (weak, nonatomic) IBOutlet UIView *gameView;

@property (strong, nonatomic) BowlingBallView* idleBallView;
@property (strong, nonatomic) BowlingBallView* rollingBallView;

@property (strong, nonatomic) NSMutableArray* pinViews;
@property (strong, nonatomic) NSMutableArray* pinFrames;
@property (strong, nonatomic) NSMutableArray* pinStandings;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collider;
@property (strong, nonatomic) UIDynamicItemBehavior *animationOptions;

@property (nonatomic) CGFloat lastPositionX;
@property (nonatomic) BOOL waitingToCheckScore;

@end

@implementation BowlingViewController

static const int NUM_PINS = 10;

static const CGFloat GESTURE_TO_SPEED_FACTOR = 2;

static const CGFloat LINE_OFFSET = 150.0;  // Distance from bottom to the foul line
static const CGFloat BALL_OFFSET = 100.0;  // Distance from bottom to origin for starting ball position
static const CGFloat BALL_WIDTH = 50.0;    // The bowling ball's width
static const CGFloat PIN_WIDTH = 24.0;     // The bowling pin's width
static const CGFloat PIN_DELTA_X = 28.0;   // The horizontal spacing between pins in the same row
static const CGFloat PIN_DELTA_Y = 45.0;   // The vertical spacing between pins in adjacent rows
static const CGFloat PIN_OFFSET = 20.0;    // Distance from top of screen to origin of pins

#pragma mark - Properties

- (NSMutableArray *)pinViews {
    if (!_pinViews) {
        _pinViews = [[NSMutableArray alloc] init];
    }
    return _pinViews;
}

- (NSMutableArray *)pinFrames {
    if (!_pinFrames) {
        _pinFrames = [[NSMutableArray alloc] init];
    }
    return _pinFrames;
}

- (NSMutableArray *)pinStandings {
    if (!_pinStandings) {
        _pinStandings = [[NSMutableArray alloc] init];
    }
    return _pinStandings;
}

#pragma mark - Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];

    self.collider = [[UICollisionBehavior alloc] init];
    [self.animator addBehavior:self.collider];

    self.animationOptions = [[UIDynamicItemBehavior alloc] init];
    self.animationOptions.density = 2.0;
    // The dynamic item behavior is only added when the user rolls the ball

    __weak BowlingViewController *weakSelf = self;
    self.animationOptions.action = ^{
        if (weakSelf.waitingToCheckScore) {
            return;
        }
        if (!CGRectIntersectsRect(weakSelf.gameView.bounds, weakSelf.rollingBallView.frame)) {
            weakSelf.waitingToCheckScore = YES;
            [NSTimer scheduledTimerWithTimeInterval:4
                                             target:weakSelf
                                           selector:@selector(checkScore)
                                           userInfo:nil
                                            repeats:NO];
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self determinePinsPlacement];
    [self createElements];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeElements];
}

#pragma mark - Internal Functions

- (void)checkScore {
    NSLog(@"Check score");
    self.waitingToCheckScore = NO;
    [self removeElements];
    [self createElements];
}

- (void)determinePinsPlacement {
    // The pins are positioned in the following sequence: 7, 8, 9, 10, 4, 5, 6, 2, 3, 1
    CGFloat middle = self.gameView.bounds.size.width / 2;
    CGPoint startingPoint = CGPointMake(middle - 2 * PIN_WIDTH - 1.5 * PIN_DELTA_X, PIN_OFFSET);
    CGRect frame = CGRectMake(startingPoint.x, startingPoint.y, PIN_WIDTH, PIN_WIDTH);

    int pinsInRow = 4;
    int count = 0;

    for (int num = 0; num < NUM_PINS; num++) {
        [self.pinFrames addObject:[NSValue valueWithCGRect:frame]];
        if (++count == pinsInRow) {
            // Move to the next row
            startingPoint.x += (PIN_WIDTH + PIN_DELTA_X) / 2;
            startingPoint.y += PIN_DELTA_Y;
            frame.origin.x = startingPoint.x;
            frame.origin.y = startingPoint.y;
            pinsInRow--;
            count = 0;
        } else {
            // Stay in the same row
            frame.origin.x += PIN_WIDTH + PIN_DELTA_X;
        }
    }
}

- (void)createElements {
    // Create the idle ball
    CGRect ballFrame = CGRectMake((self.gameView.bounds.size.width - BALL_WIDTH) / 2,
                                     self.gameView.bounds.size.height - BALL_OFFSET,
                                     BALL_WIDTH,
                                     BALL_WIDTH);
    self.idleBallView = [[BowlingBallView alloc] initWithFrame:ballFrame];
    [self.gameView addSubview:self.idleBallView];

    // Add a pan gesture for the ball
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.idleBallView addGestureRecognizer:self.panGestureRecognizer];

    // Create the pins
    [self createPins];
}

- (void)createPins {
    for (int num = 0; num < NUM_PINS; num++) {
        CGRect pinFrame = [self.pinFrames[num] CGRectValue];
        BowlingPinView *pinView = [[BowlingPinView alloc] initWithFrame:pinFrame];
        [self.gameView addSubview:pinView];
        [self.collider addItem:pinView];
        [self.pinViews addObject:pinView];
    }
}

- (void)removeElements {
    [self removeIdleBall];
    [self removeRollingBall];
    [self removePins];
}

- (void)removeIdleBall {
    if (self.idleBallView) {
        [self.idleBallView removeGestureRecognizer:self.panGestureRecognizer];
        [self.idleBallView removeFromSuperview];
        self.idleBallView = nil;
        self.panGestureRecognizer = nil;
    }
}

- (void)removeRollingBall {
    if (self.rollingBallView) {
        // Remove dynamic item behavior animations
        [self.animator removeBehavior:self.animationOptions];

        [self.animationOptions removeItem:self.rollingBallView];
        [self.collider removeItem:self.rollingBallView];
        [self.rollingBallView removeFromSuperview];
        self.rollingBallView = nil;
    }
}

- (void)removePins {
    // Remove pins from view
    for (UIView *pinView in self.pinViews) {
        [self.collider removeItem:pinView];
        [pinView removeFromSuperview];
    }
    [self.pinViews removeAllObjects];
}

#pragma mark - Gestures

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint gesturePoint = [gesture locationInView:self.gameView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.lastPositionX = gesturePoint.x;
            break;
        case UIGestureRecognizerStateChanged:
            if (gesturePoint.y < self.gameView.bounds.size.height - LINE_OFFSET) {
                // User crossed the foul line. Release the ball.
                CGRect frame = self.idleBallView.frame;

                // Remove idle ball view
                [self removeIdleBall];

                // Add dynamic item animator
                [self.animator addBehavior:self.animationOptions];

                // Add rolling ball
                self.rollingBallView = [[BowlingBallView alloc] initWithFrame:frame];
                [self.gameView addSubview:self.rollingBallView];
                [self.animationOptions addItem:self.rollingBallView];
                [self.collider addItem:self.rollingBallView];

                CGPoint velocity = [gesture velocityInView:self.gameView];
                velocity.x /= GESTURE_TO_SPEED_FACTOR;
                velocity.y /= GESTURE_TO_SPEED_FACTOR;
                [self.animationOptions addLinearVelocity:velocity
                                                 forItem:self.rollingBallView];
            }
            else if (gesturePoint.y > self.idleBallView.frame.origin.y) {
                // Move the ball horizontally depending on position change
                CGFloat delta = gesturePoint.x - self.lastPositionX;
                self.lastPositionX = gesturePoint.x;
                CGFloat newOriginX = self.idleBallView.frame.origin.x + delta;

                if (newOriginX < 0) {
                    newOriginX = 0;
                } else if (newOriginX + BALL_WIDTH > self.gameView.bounds.size.width) {
                    newOriginX = self.gameView.bounds.size.width - BALL_WIDTH;
                }
                self.idleBallView.transform = CGAffineTransformTranslate(self.idleBallView.transform, newOriginX - self.idleBallView.frame.origin.x, 0);
            }
            break;
        default:
            // do nothing
            break;
    }
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    // Recreate the elements
    [self removeElements];
    [self createElements];
}

@end
