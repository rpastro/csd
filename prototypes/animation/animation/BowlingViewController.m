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
@property (strong, nonatomic) BallView* ball;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collider;
@property (strong, nonatomic) UIDynamicItemBehavior *animationOptions;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@end

@implementation BowlingViewController

static const NSString *LEFT_BOUNDARY_ID = @"LEFT";
static const NSString *RIGHT_BOUNDARY_ID = @"RIGHT";
static const NSString *BOTTOM_BOUNDARY_ID = @"BACK";

static const CGFloat GESTURE_TO_SPEED_FACTOR = 5;

static const CGFloat LINE_OFFSET = 150.0;  // Distance from bottom to the foul line
static const CGFloat BALL_OFFSET = 100.0;  // Distance from bottom to origin for starting ball position
static const CGFloat BALL_WIDTH = 50.0;    // The bowling ball's width

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
        //_collider.translatesReferenceBoundsIntoBoundary = YES;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0, self.gameView.bounds.size.height)];
        [path addLineToPoint:CGPointMake(self.gameView.bounds.size.width, self.gameView.bounds.size.height)];
        //[path addLineToPoint:CGPointMake(self.gameView.bounds.size.width, 0)];
        [_collider addBoundaryWithIdentifier:LEFT_BOUNDARY_ID forPath:path];
        [self.animator addBehavior:_collider];
    }
    return _collider;
}

- (UIDynamicItemBehavior *)animationOptions {
    if (!_animationOptions) {
        _animationOptions = [[UIDynamicItemBehavior alloc] init];
        _animationOptions.allowsRotation = NO;
        [self.animator addBehavior:_animationOptions];
    }
    return _animationOptions;
}


- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setBowlingBall];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBowlingBall {
    CGRect ballFrame;
    ballFrame.origin = CGPointMake((self.gameView.bounds.size.width - BALL_WIDTH) / 2,
                               self.gameView.bounds.size.height - BALL_OFFSET);
    ballFrame.size = CGSizeMake(BALL_WIDTH, BALL_WIDTH);
    self.ball = [[BallView alloc] initWithFrame:ballFrame];
    [self.gameView addSubview:self.ball];

    [self.animationOptions addItem:self.ball];
    [self.collider addItem:self.ball];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint gesturePoint = [gesture locationInView:self.gameView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self attachBallToPoint:gesturePoint];
            break;
        case UIGestureRecognizerStateChanged:
            self.attachment.anchorPoint = gesturePoint;
            if (gesturePoint.y < self.gameView.bounds.size.height - LINE_OFFSET) {
                [self.animator removeBehavior:self.attachment];
                CGPoint velocity = [gesture velocityInView:self.gameView];
                velocity.x /= GESTURE_TO_SPEED_FACTOR;
                velocity.y /= GESTURE_TO_SPEED_FACTOR;
                [self.animationOptions addLinearVelocity:velocity
                                                 forItem:self.ball];
            }
            break;
        case UIGestureRecognizerStateEnded:
            [self.animator removeBehavior:self.attachment];
            break;
        default:
            // do nothing
            break;
    }
}

- (void)attachBallToPoint:(CGPoint)anchorPoint {
    if (self.ball) {
        self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self.ball
                                                    attachedToAnchor:anchorPoint];
        [self.animator addBehavior:self.attachment];
    }
}

@end
