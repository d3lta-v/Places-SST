//
//  Places_SSTTests.m
//  Places@SSTTests
//
//  Created by Pan Ziyue on 20/9/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "PlacesKit.h"

@interface Places_SSTTests : XCTestCase

@property (nonatomic) ViewController *firstVCTest;

@end

@implementation Places_SSTTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.firstVCTest = [ViewController new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"passed");
}

-(void)testSignalImage {
    UIImage *image0 = [self.firstVCTest applySignal:0];
    UIImage *expectedImage0 = [PlacesKit imageOfNone];
    
    XCTAssertEqualObjects(image0, expectedImage0, @"Expected image 0, or image of none");
}


@end
