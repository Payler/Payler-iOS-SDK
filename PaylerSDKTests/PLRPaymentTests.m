//
//  PLRPaymentTests.m
//  PaylerSDK
//
//  Created by Максим Павлов on 10.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PLRPayment.h"

#define EXP_SHORTHAND YES
#import <Expecta.h>

#pragma clang diagnostic ignored "-Wnonnull"

@interface PLRPaymentTests : XCTestCase

@property (nonatomic, strong) PLRPayment *payment;

@end

@implementation PLRPaymentTests

- (void)testPaymentCreationWithoutIdShouldRaiseException {
    __block PLRPayment *payment;
    expect(^{
        payment = [[PLRPayment alloc] initWithId:nil amount:0.0];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testPaymentCreationWithIdAndAmount {
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"uniqueId" amount:100];

    expect(payment.paymentId).to.equal(@"uniqueId");
    expect(payment.amount).to.equal(100);
    expect(payment.status).to.equal(PLRPaymentStatusUnknown);
    expect(payment.product).to.beNil();
    expect(payment.total).to.equal(CGFLOAT_MIN);
}

- (void)testPaymentCreationWithIdAmountAndStatus {
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"uniqueId" amount:100 status:@"Refunded"];

    expect(payment.paymentId).to.equal(@"uniqueId");
    expect(payment.amount).to.equal(100);
    expect(payment.status).to.equal(PLRPaymentStatusRefunded);
    expect(payment.product).to.beNil();
    expect(payment.total).to.equal(CGFLOAT_MIN);
}

- (void)testPaymentCreationWithAllParameters {
    [self setupPaymentWithAllParameters];

    expect(self.payment.paymentId).to.equal(@"uniqueId");
    expect(self.payment.amount).to.equal(100);
    expect(self.payment.status).to.equal(PLRPaymentStatusCharged);
    expect(self.payment.product).to.equal(@"Product");
    expect(self.payment.total).to.equal(25.5);
    expect(self.payment.parameters).to.equal(@{@"userData": @"test@test.com"});
}

- (void)testDictionaryRepresentationForPaymentWithDefaultParameters {
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"uniqueId" amount:100];
    NSDictionary *parameters = @{@"order_id": @"uniqueId", @"amount": @(100)};

    expect([payment dictionaryRepresentation]).to.equal(parameters);
}

- (void)testDictionaryRepresentationForPaymentWithAllParameters {
    [self setupPaymentWithAllParameters];

    NSDictionary *parameters = @{@"order_id": @"uniqueId", @"amount": @(100), @"product": @"Product", @"total": @(25.5), @"userData": @"test@test.com"};
    expect([self.payment dictionaryRepresentation]).to.equal(parameters);
}

- (void)testPaymentTemplateCreationWithoutIdShouldRaiseException {
    __block PLRPaymentTemplate *template;
    expect(^{
        template = [[PLRPaymentTemplate alloc] initWithTemplateId:nil];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testPaymentTemplateCreationWithId {
    PLRPaymentTemplate *template = [[PLRPaymentTemplate alloc] initWithTemplateId:@"id"];
    expect(template.recurrentTemplateId).to.equal(@"id");
}

- (void)setupPaymentWithAllParameters {
    self.payment = [[PLRPayment alloc] initWithId:@"uniqueId" amount:100 status:@"Charged" product:@"Product" total:25.5 parameters:@{@"userData": @"test@test.com"}];
}

@end
