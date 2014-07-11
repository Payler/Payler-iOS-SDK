//
//  PLRPayment.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRPayment.h"

NSString *const PLRPaymentStatusCreatedKey = @"Created";
NSString *const PLRPaymentStatusPreAuthorized3DSKey = @"PreAuthorized3DS";
NSString *const PLRPaymentStatusPreAuthorizedAFKey = @"PreAuthorizedAF";
NSString *const PLRPaymentStatusAuthorizedKey = @"Authorized";
NSString *const PLRPaymentStatusRetrievedKey = @"Retrieved";
NSString *const PLRPaymentStatusReversedKey = @"Reversed";
NSString *const PLRPaymentStatusChargedKey = @"Charged";
NSString *const PLRPaymentStatusRefundedKey = @"Refunded";
NSString *const PLRPaymentStatusRejectedKey = @"Rejected";
NSString *const PLRPaymentStatusErrorKey = @"Error";

NSDictionary *PLRPaymentStatusMappingDictionary() {
    return @{PLRPaymentStatusCreatedKey: @(PLRPaymentStatusCreated),
             PLRPaymentStatusPreAuthorized3DSKey: @(PLRPaymentStatusPreAuthorized3DS),
             PLRPaymentStatusPreAuthorizedAFKey: @(PLRPaymentStatusPreAuthorizedAF),
             PLRPaymentStatusAuthorizedKey: @(PLRPaymentStatusAuthorized),
             PLRPaymentStatusRetrievedKey: @(PLRPaymentStatusRetrieved),
             PLRPaymentStatusReversedKey: @(PLRPaymentStatusReversed),
             PLRPaymentStatusChargedKey: @(PLRPaymentStatusCharged),
             PLRPaymentStatusRefundedKey: @(PLRPaymentStatusRefunded),
             PLRPaymentStatusRejectedKey:@(PLRPaymentStatusRejected),
             PLRPaymentStatusErrorKey: @(PLRPaymentStatusError)};
};

@interface PLRPayment ()
@property (nonatomic, readwrite, copy) NSString *paymentId;
@property (nonatomic, readwrite, assign) NSInteger amount;
@property (nonatomic, readwrite, copy) NSString *product;
@property (nonatomic, readwrite, assign) CGFloat total;
@end

@implementation PLRPayment

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount {
    return [self initWithId:paymentId amount:amount status:nil];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount status:(NSString *)status {
    return [self initWithId:paymentId amount:amount status:status product:nil total:CGFLOAT_MIN];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount status:(NSString *)status product:(NSString *)product total:(CGFloat)total {
    self = [super init];
    if (self) {
        if (!paymentId) [NSException raise:@"RequiredParameter" format:@"'paymentId' is required."];

        _paymentId = paymentId;
        _amount = amount;
        _status = status ? [[PLRPaymentStatusMappingDictionary() objectForKey:status] integerValue] : PLRPaymentStatusUnknown;
        _product = [product copy];
        _total = total;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"order_id"] = self.paymentId;
    parameters[@"amount"] = @(self.amount);
    if (self.product.length) parameters[@"product"] = self.product;
    if (self.total > CGFLOAT_MIN) parameters[@"total"] = @(self.total);
    return [parameters copy];
}

- (NSString *)description {
    return [[self dictionaryRepresentation] description];
}

@end
