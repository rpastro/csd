//
//  WeBowlerTests.m
//  WeBowlerTests
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BowlingFrame.h"
#import "BowlingGame.h"


@interface WeBowlerTests : XCTestCase

@end

@implementation WeBowlerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFrameInitialization {

    BowlingFrame *frame = [[BowlingFrame alloc] init];
    XCTAssert([frame getScore] == 0);
    XCTAssert(!frame.finished);
    XCTAssert(!frame.isSpare);
    XCTAssert(!frame.isStrike);
}

- (void)testFramePlayFirstBallNotStrike {

    BowlingFrame *frame = [[BowlingFrame alloc] init];
    [frame dropPins:8];
    XCTAssert(![frame isStrike ]);
}

- (void)testFrameScore_BadFrame {
    BowlingFrame *frame = [[BowlingFrame alloc] init];
    [frame dropPins:3];
    [frame dropPins:5];
    XCTAssertEqual([frame getScore], 8);
}

- (void)testFrameScore_SpareFrame {
    BowlingFrame *frame = [[BowlingFrame alloc] init];
    [frame dropPins:3];
    [frame dropPins:7];
    [frame addBonusBall:10];
    XCTAssertEqual([frame getScore], 20);
}

- (void)testFrameScore_StrikeFrame {
    BowlingFrame *frame = [[BowlingFrame alloc] init];
    [frame dropPins:10];
    [frame addBonusBall:3];
    [frame addBonusBall:5];
    XCTAssertEqual([frame getScore], 18);
}

- (void)testLowGameScore {
    BowlingGame *game = [[BowlingGame alloc] init];
    while (!game.finished)
    {
        [game rollBall:1];
    }
    XCTAssertEqual([game getScore], 20);
}

- (void)testAllSparesGameScore {
    BowlingGame *game = [[BowlingGame alloc] init];
    while (!game.finished)
    {
        [game rollBall:5];
    }
    XCTAssertEqual([game getScore], 150);
}

- (void)testPerfectGameScore {
    BowlingGame *game = [[BowlingGame alloc] init];
    while (!game.finished)
    {
        [game rollBall:10];
    }
    XCTAssertEqual([game getScore], 300);
}

- (void)testRemainingPins {
    BowlingGame *game = [[BowlingGame alloc] init];
    for (NSInteger n = 0; n < 9; ++n)
    {
        [game rollBall:2];
        [game rollBall:game.remainingPins];
    }
    //is tenth frame now
    [game rollBall:10];
    [game rollBall:8];

    XCTAssertEqual(game.remainingPins, 2);
    [game rollBall:0];
    XCTAssertEqual([game getScore], 134);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
