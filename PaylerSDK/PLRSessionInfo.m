//
//  PLRSessionInfo.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRSessionInfo.h"
#import "PLRPayment.h"

NSString *const PLRSessionEnumToString[] = {
    [PLRSessionTypeOneStep] = @"Pay",
    [PLRSessionTypeTwoStep] = @"Block"
};

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
        if (!paymentInfo) [NSException raise:@"RequiredParameter" format:@"'paymentInfo' is required."];
        
        _paymentInfo = paymentInfo;
        _sessionType = sessionType;
        _templateName = templateName;
        _language = language;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"type"] = PLRSessionEnumToString[self.sessionType];
    parameters[@"template"] = self.templateName.length ? self.templateName : @"mobile";
    if (self.language.length) parameters[@"language"] = self.language;
    [parameters addEntriesFromDictionary:[self.paymentInfo dictionaryRepresentation]];
    return [parameters copy];
}

- (NSString *)description {
    return [[self dictionaryRepresentation] description];
}

@end
