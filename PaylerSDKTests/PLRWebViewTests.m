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

#pragma clang diagnostic ignored "-Wnonnull"

@interface PLRWebViewTests : XCTestCase

@property (nonatomic, strong) PLRWebView *webView;

@end

@implementation PLRWebViewTests

- (void)setUp {
    [super setUp];

    self.webView = [[PLRWebView alloc] init];
}

- (void)testPayWithoutDataSourceShouldRaiseException {
    expect(^{
        [self.webView payWithCompletion:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testSettingInvalidDataSourceShouldRaiseException {
    expect(^{
        self.webView.dataSource = OCMClassMock([NSObject class]);
    }).to.raise(NSInvalidArgumentException);
}

- (void)testSettingValidDataSource {
    expect(^{
        self.webView.dataSource = OCMProtocolMock(@protocol(PLRWebViewDataSource));
    }).notTo.raiseAny();
}

- (void)testPayWithoutSessionInfoShouldRaiseException {
    expect(^{
        id<PLRWebViewDataSource> dataSource = OCMProtocolMock(@protocol(PLRWebViewDataSource));
        OCMStub([dataSource webViewClient:OCMOCK_ANY]).andReturn(OCMClassMock([PaylerAPIClient class]));
        self.webView.dataSource = dataSource;
        [self.webView payWithCompletion:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testPayWithoutClientShouldRaiseException {
    expect(^{
        id<PLRWebViewDataSource> dataSource = OCMProtocolMock(@protocol(PLRWebViewDataSource));
        OCMStub([dataSource webViewSessionInfo:OCMOCK_ANY]).andReturn(OCMClassMock([PLRSessionInfo class]));
        self.webView.dataSource = dataSource;
        [self.webView payWithCompletion:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testPayWithSessionInfoAndClient {
    expect(^{
        id<PLRWebViewDataSource> dataSource = OCMProtocolMock(@protocol(PLRWebViewDataSource));
        PaylerAPIClient *client = OCMClassMock([PaylerAPIClient class]);
        OCMStub([client startSessionWithInfo:[OCMArg isNotNil] completion:[OCMArg isNotNil]]).andDo(nil);
        OCMStub([dataSource webViewClient:OCMOCK_ANY]).andReturn(client);
        OCMStub([dataSource webViewSessionInfo:OCMOCK_ANY]).andReturn(OCMClassMock([PLRSessionInfo class]));

        self.webView.dataSource = dataSource;
        [self.webView payWithCompletion:nil];
    }).notTo.raiseAny();
}

@end
