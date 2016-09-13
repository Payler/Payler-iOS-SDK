//
//  PLRPayment.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRPayment.h"

NSString *const PLRPaymentStatusCreatedKey          = @"Created";
NSString *const PLRPaymentStatusPreAuthorized3DSKey = @"PreAuthorized3DS";
NSString *const PLRPaymentStatusPreAuthorizedAFKey  = @"PreAuthorizedAF";
NSString *const PLRPaymentStatusAuthorizedKey       = @"Authorized";
NSString *const PLRPaymentStatusRetrievedKey        = @"Retrieved";
NSString *const PLRPaymentStatusReversedKey         = @"Reversed";
NSString *const PLRPaymentStatusChargedKey          = @"Charged";
NSString *const PLRPaymentStatusRefundedKey         = @"Refunded";
NSString *const PLRPaymentStatusRejectedKey         = @"Rejected";
NSString *const PLRPaymentStatusErrorKey            = @"Error";

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
@property (nonatomic, readwrite, assign) NSUInteger amount;
@property (nonatomic, readwrite, assign) PLRPaymentStatus status;
@property (nonatomic, readwrite, copy) NSString *product;
@property (nonatomic, readwrite, assign) CGFloat total;
@property (nonatomic, readwrite, copy) NSDictionary *parameters;
@end

@implementation PLRPayment

- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount {
    return [self initWithId:paymentId amount:amount status:nil];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount status:(NSString *)status {
    return [self initWithId:paymentId amount:amount status:status product:nil total:CGFLOAT_MIN parameters:nil];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount status:(NSString *)status product:(NSString *)product total:(CGFloat)total parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        if (!paymentId) [NSException raise:NSInvalidArgumentException format:@"'paymentId' is required."];
        if (paymentId.length > 100 || product.length > 100) [NSException raise:NSInvalidArgumentException format:@"String length must be less than or equal 100 symbols."];

        _paymentId = paymentId;
        _amount = amount;
        _status = status ? [[PLRPaymentStatusMappingDictionary() objectForKey:status] integerValue] : PLRPaymentStatusUnknown;
        _product = [product copy];
        _total = total;
        _parameters = [parameters copy];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"order_id"] = self.paymentId;
    parameters[@"amount"] = @(self.amount);
    if (self.product.length) parameters[@"product"] = self.product;
    if (self.total > CGFLOAT_MIN) parameters[@"total"] = @(self.total);
    [parameters addEntriesFromDictionary:self.parameters];
    return [parameters copy];
}

- (NSString *)description {
    return [[self dictionaryRepresentation] description];
}

@end

@interface PLRPaymentTemplate ()
@property (nonatomic, readwrite, copy) NSString *recurrentTemplateId;
@end

@implementation PLRPaymentTemplate

- (instancetype)initWithTemplateId:(NSString *)recurrentTemplateId {
    self = [super init];
    if (self) {
        if (!recurrentTemplateId) [NSException raise:NSInvalidArgumentException format:@"'recurrentTemplateId' is required."];
        
        _recurrentTemplateId = [recurrentTemplateId copy];
    }
    return self;
}

@end
