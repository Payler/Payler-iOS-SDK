//
//  Payler.h
//  PaylerSDK
//
//  Created by Максим Павлов on 08.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

@class PLRPayment;

typedef void(^PLRCompletionBlock)(PLRPayment *payment, NSDictionary *info, NSError *error);
typedef void(^PLRFetchStatusCompletionBlock)(PLRPayment *payment, NSString *status, NSDictionary *info, NSError *error);

@interface PaylerAPIClient : AFHTTPRequestOperationManager

- (instancetype)initWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword;

@end

@interface PaylerAPIClient (Requests)

- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRFetchStatusCompletionBlock)completion;

@end

extern NSString *const PaylerErrorDomain;