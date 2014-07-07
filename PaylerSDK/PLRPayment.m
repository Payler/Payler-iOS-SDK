//
//  PLRPayment.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRPayment.h"

@interface PLRPayment ()
@property (nonatomic, readwrite, assign) NSInteger paymentId;
@property (nonatomic, readwrite, assign) NSInteger amount;
@property (nonatomic, readwrite, copy) NSString *product;
@property (nonatomic, readwrite, assign) CGFloat total;
@end

@implementation PLRPayment

- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount {
    return [self initWithId:paymentId amount:amount product:nil total:0.0];
}

- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount product:(NSString *)product {
    return [self initWithId:paymentId amount:amount product:product total:0.0];
}

- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount product:(NSString *)product total:(CGFloat)total {
    self = [super init];
    if (self) {
        _paymentId = paymentId;
        _amount = amount;
        _product = [product copy];
        _total = total;
    }
    return self;
}

@end
