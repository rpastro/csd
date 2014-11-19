//
//  ViewController.m
//  WeBowler
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import "GameViewController.h"
#import "BowlingBallView.h"
#import "BowlingPinView.h"
#import "BowlingGame.h"
#import "BowlingFrame.h"

@interface GameViewController ()

@property (strong, nonatomic) BowlingGame *game;
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (weak, nonatomic) IBOutlet UILabel *frameNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapToContinueLabel;

@property (strong, nonatomic) BowlingBallView* idleBallView;
@property (strong, nonatomic) BowlingBallView* rollingBallView;

@property (strong, nonatomic) NSMutableArray* pinViews;
@property (strong, nonatomic) NSMutableArray* pinFrames;
@property (strong, nonatomic) NSMutableArray* droppedPins;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collider;
@property (strong, nonatomic) UIDynamicItemBehavior *animationOptions;

@property (nonatomic) CGFloat lastPositionX;
@property (nonatomic) BOOL waitingToCheckScore;

@end

@implementation GameViewController

static const int NUM_PINS = 10;

static const CGFloat GESTURE_TO_SPEED_FACTOR = 2;

static const CGFloat LINE_OFFSET = 150.0;  // Distance from bottom to the foul line
static const CGFloat BALL_OFFSET = 100.0;  // Distance from bottom to origin for starting ball position
static const CGFloat BALL_WIDTH = 50.0;    // The bowling ball's width
static const CGFloat PIN_WIDTH = 24.0;     // The bowling pin's width
static const CGFloat PIN_OFFSET = 20.0;    // Distance from top of screen to origin of pins
static const CGFloat PIN_DELTA_X = 24.0;   // The horizontal spacing between pins in the same row
static const CGFloat MINIMUM_PIN_MOVEMENT = 4.0; // The minimum number of points the PIN needs to be considered down

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

- (NSMutableArray *)droppedPins {
    if (!_droppedPins) {
        _droppedPins = [[NSMutableArray alloc] init];
    }
    return _droppedPins;
}

#pragma mark - Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.game = [[BowlingGame alloc] init];
    [self setBottomLabels:NO];

    self.scoreLabel.text = @"";
    self.scoreLabel.hidden = YES;
    self.tapToContinueLabel.hidden = YES;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];

    self.collider = [[UICollisionBehavior alloc] init];
    [self.animator addBehavior:self.collider];

    self.animationOptions = [[UIDynamicItemBehavior alloc] init];
    self.animationOptions.density = 1.8; // Default density is 1.0
    // The dynamic item behavior is only added when the user rolls the ball

    __weak GameViewController *weakSelf = self;
    self.animationOptions.action = ^{
        if (weakSelf.waitingToCheckScore || !weakSelf.rollingBallView) {
            return;
        }
        if (!CGRectIntersectsRect(weakSelf.gameView.bounds, weakSelf.rollingBallView.frame)) {
            weakSelf.waitingToCheckScore = YES;
            [NSTimer scheduledTimerWithTimeInterval:2
                                             target:weakSelf
                                           selector:@selector(computeScore)
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

- (void)computeScore {
    [self removeRollingBall];
    self.waitingToCheckScore = NO;

    NSUInteger numDroppedPins = 0;
    for (int idx = 0; idx < NUM_PINS; idx++) {
        BOOL dropped = YES;
        if ([self.pinViews[idx] isKindOfClass:[BowlingPinView class]]) {
            BowlingPinView *pinView = (BowlingPinView *)self.pinViews[idx];
            CGRect pinFrame = [self.pinFrames[idx] CGRectValue];
            CGRect expectedArea = CGRectMake(pinFrame.origin.x - MINIMUM_PIN_MOVEMENT,
                                             pinFrame.origin.y - MINIMUM_PIN_MOVEMENT,
                                             2 * MINIMUM_PIN_MOVEMENT,
                                             2 * MINIMUM_PIN_MOVEMENT);
            dropped = !CGRectContainsPoint(expectedArea, pinView.frame.origin);
            if (dropped) {
                numDroppedPins++;
            }
        }
        [self.droppedPins addObject:[NSNumber numberWithBool:dropped]];
    }

    BOOL resetPins = [self.game rollBall:numDroppedPins];
    if (resetPins) {
        [self.droppedPins removeAllObjects];
    }
    [self setBottomLabels:YES];

    if (self.game.finished) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%lu", [self.game getScore]];
        self.tapToContinueLabel.text = @"Tap to start new game";
    } else {
        self.scoreLabel.text = self.game.lastBallScore;
    }
    self.scoreLabel.hidden = NO;
    self.tapToContinueLabel.hidden = NO;

    NSLog(@"Score: %@", [self.game generateScoreboard]);
}

- (void)determinePinsPlacement {
    // Calculate the vertical spacing between pins in adjacent rows
    CGFloat pinDeltaY = tan(M_PI / 3) * (PIN_WIDTH + PIN_DELTA_X) / 2;

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
            startingPoint.y += pinDeltaY;
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
    if (self.game.finished) {
        // Create a new game
        self.game = [[BowlingGame alloc] init];
        self.tapToContinueLabel.text = @"Tap to continue";
    }
    [self setBottomLabels:NO];

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

- (void)setBottomLabels:(BOOL)useLastPlayedFrame {
    if (useLastPlayedFrame) {
        self.frameNumberLabel.text = [NSString stringWithFormat:@"Frame %lu", self.game.lastPlayedFrameNumber];
        self.frameScoreLabel.text = [self.game generateLastPlayedFrameScore];
    } else {
        self.frameNumberLabel.text = [NSString stringWithFormat:@"Frame %lu", self.game.currentFrameNumber];
        self.frameScoreLabel.text = [self.game generateCurrentFrameScore];
    }
    self.totalScoreLabel.text = [NSString stringWithFormat:@"%lu", [self.game getScore]];
}

- (void)createPins {
    for (int idx = 0; idx < NUM_PINS; idx++) {
        if ([self.droppedPins count] > 0 && [self.droppedPins[idx] boolValue]) {
            // Do not create a UIView for dropped pins
            [self.pinViews addObject:[NSNull null]];
            continue;
        }
        CGRect pinFrame = [self.pinFrames[idx] CGRectValue];
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
    for (int idx = 0; idx < NUM_PINS; idx++) {
        if ([self.pinViews[idx] isKindOfClass:[BowlingPinView class]]) {
            BowlingPinView *pinView = (BowlingPinView *)self.pinViews[idx];
            [self.collider removeItem:pinView];
            [pinView removeFromSuperview];
        }
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
    if (!self.tapToContinueLabel.hidden) {
        self.scoreLabel.text = @"";
        self.scoreLabel.hidden = YES;
        self.tapToContinueLabel.hidden = YES;
        
        // Recreate the elements
        [self removeElements];
        [self createElements];
    }
}

- (IBAction)quit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
