//
//  PaylerAPIClientTests.m
//  PaylerSDK
//
//  Created by Максим Павлов on 10.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PaylerAPIClient.h"
#import "PLRSessionInfo.h"
#import "PLRPayment.h"
#import <OCMock.h>

#define EXP_SHORTHAND YES
#import <Expecta.h>
#import <OHHTTPStubs.h>

@interface PaylerAPIClientTests : XCTestCase

@property (nonatomic, strong) PaylerAPIClient *client;
@property (nonatomic, strong) PLRPayment *payment;

@end

@implementation PaylerAPIClientTests

- (void)setUp
{
    [super setUp];

    self.client = [[PaylerAPIClient alloc] init];
    self.payment = [[PLRPayment alloc] initWithId:@"SDK_iOS_2014-07-10 10:48:09  0000" amount:100];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testClientCreationWithNilArguments {
    expect([self.client.baseURL absoluteString]).to.equal(@"https://sandbox.payler.com/gapi/");
}

- (void)testClientCreationWithNonNilArguments {
    PaylerAPIClient *client = [[PaylerAPIClient alloc] initWithMerchantKey:@"MerchantKey" password:@"MerchantPassword"];
    expect([client.baseURL absoluteString]).to.equal(@"https://secure.payler.com/gapi/");
}

- (void)testClientSecurityPolicy {
    expect(self.client.securityPolicy.SSLPinningMode).to.equal(AFSSLPinningModeCertificate);
}

- (void)testStartSession {
    [self setupStubWithURL:@"StartSession" filePath:@"StartSession.txt"];

    PLRSessionInfo *sessionInfo = OCMClassMock([PLRSessionInfo class]);
    __block NSString *sessionId;
    [self.client startSessionWithInfo:sessionInfo completion:^(PLRPayment *fetchedPayment, NSString *fetchedSessionId, NSDictionary *info, NSError *error) {
        sessionId = fetchedSessionId;

        expect(self.payment.paymentId).to.equal(fetchedPayment.paymentId);
        expect(self.payment.amount).to.equal(fetchedPayment.amount);
        expect(sessionId).to.equal(@"ce609441-784d-4a13-80a8-47da576e6100");
        expect(error).to.beNil();
    }];

    expect(sessionId).willNot.beNil();
    OCMVerify([sessionInfo dictionaryRepresentation]);
}

- (void)testChargePayment {
    [self setupStubWithURL:@"Charge" filePath:@"Charge.txt"];

    __block PLRPayment *payment;
    [self.client chargePayment:self.payment completion:^(PLRPayment *fetchedPayment, NSDictionary *info, NSError *error) {
        payment = fetchedPayment;

        expect(payment.paymentId).to.equal(self.payment.paymentId);
        expect(payment.amount).to.equal(self.payment.amount);
        expect(error).to.beNil();
    }];

    expect(payment).willNot.beNil();
}

- (void)testRetrievePayment {
    [self setupStubWithURL:@"Retrieve" filePath:@"Retrieve.txt"];

    __block PLRPayment *payment;
    [self.client retrievePayment:self.payment completion:^(PLRPayment *fetchedPayment, NSDictionary *info, NSError *error) {
        payment = fetchedPayment;

        expect(payment.paymentId).to.equal(self.payment.paymentId);
        expect(payment.amount).to.equal(0);
        expect(error).to.beNil();
    }];

    expect(payment).willNot.beNil();
}

- (void)testRefundPayment {
    [self setupStubWithURL:@"Refund" filePath:@"Refund.txt"];

    __block PLRPayment *payment;
    [self.client refundPayment:self.payment completion:^(PLRPayment *fetchedPayment, NSDictionary *info, NSError *error) {
        payment = fetchedPayment;

        expect(fetchedPayment.paymentId).to.equal(self.payment.paymentId);
        expect(fetchedPayment.amount).to.equal(0);
        expect(error).to.beNil();
    }];

    expect(payment).willNot.beNil();
}

- (void)testFetchingPaymentStatus {
    [self setupStubWithURL:@"GetStatus" filePath:@"Status.txt"];

    __block PLRPaymentStatus status;
    [self.client fetchStatusForPaymentWithId:self.payment.paymentId completion:^(PLRPayment *payment, NSDictionary *info, NSError *error) {
        status = payment.status;

        expect(status).to.equal(PLRPaymentStatusCharged);
        expect(error).to.beNil();
    }];

    expect(status).willNot.beNil();
}

- (void)testReceivingError {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.HTTPMethod isEqualToString:@"POST"] &&
        [request.URL.absoluteString isEqualToString:[self URLWithPath:@"GetStatus"]];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"Error.txt", nil) statusCode:400 headers:@{@"Content-Type": @"text/json"}];
    }];

    __block NSError *error;
    [self.client fetchStatusForPaymentWithId:self.payment.paymentId completion:^(PLRPayment *payment, NSDictionary *info, NSError *err) {
        error = err;

        expect(payment).to.beNil();
        expect(info).to.beNil();
        expect(error.domain).to.equal(PaylerErrorDomain);
        expect(error.code).to.equal(7);
    }];

    expect(error).willNot.beNil();
}

#pragma mark - Private methods

- (void)setupStubWithURL:(NSString *)URL filePath:(NSString *)filePath {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.HTTPMethod isEqualToString:@"POST"] &&
        [request.URL.absoluteString isEqualToString:[self URLWithPath:URL]];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(filePath, nil) statusCode:200 headers:@{@"Content-Type": @"text/json"}];
    }];
}

- (NSString *)URLWithPath:(NSString *)path {
    return [[NSURL URLWithString:path relativeToURL:self.client.baseURL] absoluteString];
}

@end
