//
//  PLRWebViewTests.m
//  PaylerSDK
//
//  Created by Максим Павлов on 10.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLRWebView.h"
#import <OCMock.h>
#import "PLRSessionInfo.h"
#import "PaylerAPIClient.h"

#define EXP_SHORTHAND YES
#import <Expecta.h>

@interface PLRWebViewTests : XCTestCase

@property (nonatomic, strong) PLRWebView *webView;

@end

@implementation PLRWebViewTests

- (void)setUp
{
    [super setUp];

    self.webView = [[PLRWebView alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPayWithoutSessionInfoOrClientShouldRaiseException {
    NSString *exceptionName = @"RequiredParameter";
    expect(^{
        [self.webView payWithCompletion:nil];
    }).to.raise(exceptionName);

    expect(^{
        self.webView.sessionInfo = OCMClassMock([PLRSessionInfo class]);
        [self.webView payWithCompletion:nil];
    }).to.raise(exceptionName);
}

@end
