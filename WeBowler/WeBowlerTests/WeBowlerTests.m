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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
