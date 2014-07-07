//
//  PLRSessionInfo.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRSessionInfo.h"

@interface PLRSessionInfo ()
@property (nonatomic, readwrite, strong) PLRPayment *paymentInfo;
@property (nonatomic, readwrite, assign) PLRSessionType sessionType;
@property (nonatomic, readwrite, copy) NSString *templateName;
@property (nonatomic, readwrite, copy) NSString *language;
@end

@implementation PLRSessionInfo

- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo {
    return [self initWithPaymentInfo:paymentInfo sessionType:PLRSessionTypeOneStep template:nil language:nil];
}

- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo sessionType:(PLRSessionType)sessionType {
    return [self initWithPaymentInfo:paymentInfo sessionType:sessionType template:nil language:nil];
}

- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo sessionType:(PLRSessionType)sessionType template:(NSString *)templateName language:(NSString *)language {
    self = [super init];
    if (self) {
        _paymentInfo = paymentInfo;
        _sessionType = sessionType;
        _templateName = templateName;
        _language = language;
    }
    return self;
}

@end
