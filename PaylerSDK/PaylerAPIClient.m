//
//  Payler.m
//  PaylerSDK
//
//  Created by Максим Павлов on 08.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PaylerAPIClient.h"
#import "PLRPayment.h"

@interface PaylerAPIClient ()

@property (nonatomic, copy) NSString *merchantKey;
@property (nonatomic, copy) NSString *merchantPassword;

@end

@implementation PaylerAPIClient

- (id)init {
    return [self initWithMerchantKey:nil password:nil];
}

- (instancetype)initWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword {
    BOOL merchantIdentifiersValid = merchantKey.length && merchantPassword.length;
    NSString *host = merchantIdentifiersValid ? @"secure" : @"sandbox";
    self = [super initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.payler.com/gapi", host]]];
    if (self) {
        _merchantKey = merchantIdentifiersValid ? [merchantKey copy] : @"TestMerchantBM";
        _merchantPassword = merchantIdentifiersValid ? [merchantPassword copy] : @"123";
    }
    return self;
}

- (void)enqueuePaymentRequest:(NSURLRequest *)request
                   completion:(PLRCompletionBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            PLRPayment *payment = [[PLRPayment alloc] initWithId:responseObject[@"order_id"] amount:[responseObject[@"amount"] integerValue]];
            completion(payment, responseObject[@"info"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, nil, error);
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)paymentRequestWithPath:(NSString *)path payment:(PLRPayment *)payment {
    NSParameterAssert(payment);

    return [self.requestSerializer requestWithMethod:@"POST"
                                           URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString]
                                          parameters:[self paymentParametersWithPayment:payment] error:nil];
}

- (NSDictionary *)paymentParametersWithPayment:(PLRPayment *)payment {
    NSParameterAssert(payment);

    return @{@"key": self.merchantKey, @"password": self.merchantPassword, @"order_id": payment.paymentId, @"amount": @(payment.amount)};
}

@end

@implementation PaylerAPIClient (Requests)

- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Charge" payment:payment] completion:completion];
}

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Retrieve" payment:payment] completion:completion];
}

- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Refund" payment:payment] completion:completion];
}

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRFetchStatusCompletionBlock)completion {
    NSParameterAssert(paymentId);

    NSDictionary *parameters = @{@"key": self.merchantKey, @"order_id": paymentId};
    [self POST:@"GetStatus" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            PLRPayment *payment = [[PLRPayment alloc] initWithId:responseObject[@"order_id"]
                                                          amount:[responseObject[@"amount"] integerValue]];

            completion(payment, responseObject[@"status"], responseObject[@"info"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, nil, nil, error);
        }
    }];
    
}

@end
