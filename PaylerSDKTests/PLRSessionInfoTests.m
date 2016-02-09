//
//  PLRSessionInfoTests.m
//  PaylerSDK
//
//  Created by Максим Павлов on 10.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLRSessionInfo.h"
#import "PLRPayment.h"
#import <OCMock.h>

#define EXP_SHORTHAND YES
#import <Expecta.h>

#pragma clang diagnostic ignored "-Wnonnull"

@interface PLRSessionInfoTests : XCTestCase

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PLRPayment *payment;
@property (nonatomic, strong) NSURL *callbackURL;

@end

@implementation PLRSessionInfoTests

- (void)setUp {
    [super setUp];

    self.payment = OCMClassMock([PLRPayment class]);
    NSDictionary *paymentParameters = @{@"order_id": @"id", @"amount": @(100)};
    OCMStub([self.payment dictionaryRepresentation]).andReturn(paymentParameters);

    self.callbackURL = [NSURL URLWithString:@"http://poloniumarts.com"];
    self.sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:self.payment callbackURL:self.callbackURL];
}

- (void)testSessionInfoCreationWithoutPaymentOrCallbackURLShouldRaiseException {
    __block PLRSessionInfo *sessionInfo;
    expect(^{
        sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:nil callbackURL:nil];
    }).to.raise(NSInvalidArgumentException);

    expect(^{
        sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:nil callbackURL:self.callbackURL];
    }).to.raise(NSInvalidArgumentException);

    expect(^{
        sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:self.payment callbackURL:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testSessionInfoCreationWithPaymentAndCallbackURL {
    expect(self.sessionInfo.paymentInfo).to.beIdenticalTo(self.payment);
    expect(self.sessionInfo.callbackURL).to.equal(self.callbackURL);
    expect(self.sessionInfo.sessionType).to.equal(PLRSessionTypeOneStep);
    expect(self.sessionInfo.templateName).to.beNil();
    expect(self.sessionInfo.language).to.beNil();
}

- (void)testSessionInfoCreationWithAllParameters {
    PLRSessionInfo *sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:self.payment
                                                                  callbackURL:self.callbackURL
                                                                  sessionType:PLRSessionTypeTwoStep
                                                                     template:@"myTemplate"
                                                                     language:@"ru"];
    expect(sessionInfo.paymentInfo).to.beIdenticalTo(self.payment);
    expect(sessionInfo.callbackURL).to.equal(self.callbackURL);
    expect(sessionInfo.sessionType).to.equal(PLRSessionTypeTwoStep);
    expect(sessionInfo.templateName).to.equal(@"myTemplate");
    expect(sessionInfo.language).to.equal(@"ru");
}

- (void)testDictionaryRepresentationForSessionInfoWithDefaultParameters {
    NSDictionary *parameters = @{@"type": @"OneStep", @"order_id": @"id", @"amount": @(100), @"template": @"mobile"};
    expect([self.sessionInfo dictionaryRepresentation]).to.equal(parameters);
    OCMVerify([self.payment dictionaryRepresentation]);
}

- (void)testDictionaryRepresentationForSessionInfoWithAllParameters {
    NSDictionary *parameters = @{@"type": @"TwoStep", @"order_id": @"id", @"amount": @(100), @"template": @"myTemplate", @"lang": @"en", @"recurrent": @"true"};
    PLRSessionInfo *sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:self.payment callbackURL:self.callbackURL sessionType:PLRSessionTypeTwoStep template:@"myTemplate" language:@"en"];
    sessionInfo.recurrent = YES;
    expect([sessionInfo dictionaryRepresentation]).to.equal(parameters);
    OCMVerify([self.payment dictionaryRepresentation]);
}

@end
