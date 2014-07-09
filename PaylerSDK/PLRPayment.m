//
//  PLRPayment.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRPayment.h"

@interface PLRPayment ()
@property (nonatomic, readwrite, copy) NSString *paymentId;
@property (nonatomic, readwrite, assign) NSInteger amount;
@property (nonatomic, readwrite, copy) NSString *product;
@property (nonatomic, readwrite, assign) CGFloat total;
@end

@implementation PLRPayment

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount {
    return [self initWithId:paymentId amount:amount product:nil total:0.0];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount product:(NSString *)product {
    return [self initWithId:paymentId amount:amount product:product total:0.0];
}

- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount product:(NSString *)product total:(CGFloat)total {
    self = [super init];
    if (self) {
        if (!paymentId) [NSException raise:@"Required parameter" format:@"'paymentId' is required."];

        _paymentId = paymentId;
        _amount = amount;
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
    if (self.total > 0.001) parameters[@"total"] = @(self.total);
    return [parameters copy];
}

- (NSString *)description {
    return [[self dictionaryRepresentation] description];
}

@end
