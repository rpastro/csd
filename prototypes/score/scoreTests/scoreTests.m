//
//  scoreTests.m
//  scoreTests
//
//  Created by Unify Inc on 11/17/14.
//  Copyright (c) 2014 Unify Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BowlingFrame.h"

@interface scoreTests : XCTestCase

@end

@implementation scoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNewFrame {
    BowlingFrame *newFrame = [[BowlingFrame alloc] init];
    XCTAssertFalse(newFrame.started);
    XCTAssertFalse(newFrame.finished);
}

- (void)testStartedFrame {
    BowlingFrame *newFrame = [[BowlingFrame alloc] init];
    [newFrame dropPins:5];
    XCTAssertTrue(newFrame.started);
    XCTAssertFalse(newFrame.finished);
}

- (void)testFinishedFrame {
    BowlingFrame *newFrame = [[BowlingFrame alloc] init];
    [newFrame dropPins:5];
    [newFrame dropPins:3];
    XCTAssertTrue(newFrame.started);
    XCTAssertTrue(newFrame.finished);
}

@end
