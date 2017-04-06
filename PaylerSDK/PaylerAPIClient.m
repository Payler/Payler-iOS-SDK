//
//  Payler.m
//  PaylerSDK
//
//  Created by Максим Павлов on 08.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PaylerAPIClient.h"
#import "PLRPayment.h"
#import "PLRSessionInfo.h"
#import "PLRError.h"
#import <PassKit/PassKit.h>

static NSString *const kRecurrentTemplateKey = @"recurrent_template_id";

@interface PaylerAPIClient ()

@property (nonatomic, copy) NSString *merchantKey;
@property (nonatomic, copy) NSString *merchantPassword;

@end

@implementation PaylerAPIClient

+ (instancetype)clientWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword {
    return [[self alloc] initWithHost:@"secure" merchantKey:merchantKey password:merchantPassword];
}

+ (instancetype)testClientWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword {
    return [[self alloc] initWithHost:@"sandbox" merchantKey:merchantKey password:merchantPassword];
}

- (instancetype)initWithHost:(NSString *)host merchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword {
    if (!merchantKey.length || !merchantPassword.length) [NSException raise:NSInvalidArgumentException format:@"Required parameters omitted"];

    self = [super initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.payler.com/gapi", host]]];
    if (self) {
        _merchantKey = [merchantKey copy];
        _merchantPassword = [merchantPassword copy];

        NSString *bundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"PaylerSDK" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[AFSecurityPolicy certificatesInBundle:bundle]];
    }
    return self;
}

#pragma mark - Error handling

+ (NSError *)domainErrorFromError:(NSError *)error {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (!errorData) {
        return error;
    }
    
    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
    NSDictionary *errorDictionary = [serializedData valueForKey:@"error"];
    if (![errorDictionary isKindOfClass:[NSDictionary class]]) {
        return [self invalidServerResponseError];
    }
    
    NSInteger errorCode = [errorDictionary[@"code"] integerValue];
    NSString *errorMessage = errorDictionary[@"message"];
    if ([errorMessage isKindOfClass:[NSString class]]) {
        userInfo[NSLocalizedDescriptionKey] = errorMessage;
    }
	if (error) userInfo[NSUnderlyingErrorKey] = error;
	return [NSError errorWithDomain:PaylerErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)invalidServerResponseError {
    return [NSError errorWithDomain:PaylerErrorDomain
                               code:PaylerErrorInvalidServerResponse
                           userInfo:@{NSLocalizedDescriptionKey: @"Непредвиденная ошибка"}];
}

@end

@implementation PaylerAPIClient (Payments)

- (void)startSessionWithInfo:(PLRSessionInfo *)sessionInfo completion:(PLRStartSessionCompletionBlock)completion {
    NSParameterAssert(sessionInfo);

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    [parameters addEntriesFromDictionary:[sessionInfo dictionaryRepresentation]];

    [self POST:@"StartSession" parameters:[parameters copy] progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            if ([self isStartSessionInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], responseObject[@"session_id"], nil);
            } else {
                completion(nil, nil, [self.class invalidServerResponseError]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, nil, [self.class domainErrorFromError:error]);
        }
    }];
}

- (void)fetchSessionInfoWithPaymentId:(NSString *)paymentId completion:(PLRCompletionBlock)completion {
    NSParameterAssert(paymentId.length);
    
    [self enqueueRequestWithPath:@"FindSession" paymentId:paymentId completion:completion];
}

- (void)chargePayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion {
    [self enqueuePaymentRequestWithPath:@"Charge" parameters:[self paymentParametersWithPayment:payment] completion:completion];
}

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion {
    [self enqueuePaymentRequestWithPath:@"Retrieve" parameters:[self paymentParametersWithPayment:payment] completion:completion];
}

- (void)refundPayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion {
    [self enqueuePaymentRequestWithPath:@"Refund" parameters:[self paymentParametersWithPayment:payment] completion:completion];
}

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRPaymentCompletionBlock)completion {
    NSParameterAssert(paymentId.length);

    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:0];
    [self enqueuePaymentRequestWithPath:@"GetStatus" parameters:[self parametersWithPayment:payment includePassword:NO includeAmount:NO] completion:completion];
}

- (void)fetchAdvancedStatusForPaymentWithId:(NSString *)paymentId completion:(PLRCompletionBlock)completion {
    NSParameterAssert(paymentId.length);
    
    [self enqueueRequestWithPath:@"GetAdvancedStatus" paymentId:paymentId completion:completion];
}

#pragma mark - Private methods

- (void)enqueuePaymentRequestWithPath:(NSString *)path
                           parameters:(NSDictionary *)parameters
                           completion:(PLRCompletionBlock)completion {
    [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            if ([self isPaymentInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], nil);
            } else {
                completion(nil, [self.class invalidServerResponseError]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, [self.class domainErrorFromError:error]);
        }
    }];
}

- (void)enqueueRequestWithPath:(NSString *)path paymentId:(NSString *)paymentId completion:(PLRCompletionBlock)completion {
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:0];
    [self POST:path parameters:[self parametersWithPayment:payment includePassword:NO includeAmount:NO] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, [self.class domainErrorFromError:error]);
        }
    }];
}


- (NSDictionary *)paymentParametersWithPayment:(PLRPayment *)payment {
    NSParameterAssert(payment);
    
    return [self parametersWithPayment:payment includePassword:YES includeAmount:YES];
}

- (NSDictionary *)parametersWithPayment:(PLRPayment *)payment includePassword:(BOOL)includePassword includeAmount:(BOOL)includeAmount {
    NSParameterAssert(payment);

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey, @"order_id": payment.paymentId}];
    if (includePassword) {
        parameters[@"password"] = self.merchantPassword;
    }
    
    if (includeAmount) {
        parameters[@"amount"] = @(payment.amount);
    }
    
    return [parameters copy];
}

- (BOOL)isStartSessionInfoValid:(NSDictionary *)startSessionInfo {
    return [self isPaymentInfoValid:startSessionInfo] && [startSessionInfo[@"session_id"] length];
}

- (BOOL)isPaymentInfoValid:(NSDictionary *)paymentInfo {
    NSAssert([paymentInfo isKindOfClass:[NSDictionary class]], @"Invalid argument type");

    return [paymentInfo[@"order_id"] length] && (paymentInfo[@"amount"] || paymentInfo[@"new_amount"]);
}

+ (PLRPayment *)paymentFromJSON:(NSDictionary *)JSONPayment {
    NSInteger amount = [(JSONPayment[@"amount"] ?: JSONPayment[@"new_amount"]) integerValue];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:JSONPayment[@"order_id"] amount:amount status:JSONPayment[@"status"]];
    if (JSONPayment[kRecurrentTemplateKey]) {
        payment.recurrentTemplateId = JSONPayment[kRecurrentTemplateKey];
    }
    return payment;
}

@end

@implementation PaylerAPIClient (RecurrentPayments)

- (void)repeatPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    NSParameterAssert(payment);
    NSParameterAssert(payment.recurrentTemplateId);
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self parametersWithPayment:payment includePassword:NO includeAmount:YES]];
    parameters[kRecurrentTemplateKey] = payment.recurrentTemplateId;
    [self enqueuePaymentRequestWithPath:@"RepeatPay" parameters:[parameters copy] completion:completion];
}

- (void)fetchTemplateWithId:(NSString *)recurrentTemplateId completion:(PLRCompletionBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    if (recurrentTemplateId) {
        parameters[kRecurrentTemplateKey] = recurrentTemplateId;
    }
    
    [self enqueuePaymentTemplateRequestWithPath:@"GetTemplate" parameters:[parameters copy] completion:completion];
}

- (void)activateTemplateWithId:(NSString *)recurrentTemplateId active:(BOOL)active completion:(PLRCompletionBlock)completion {
    NSParameterAssert(recurrentTemplateId);
    
    NSDictionary *parameters = @{@"key": self.merchantKey, kRecurrentTemplateKey: recurrentTemplateId, @"active": active ? @"true": @"false"};
    [self enqueuePaymentTemplateRequestWithPath:@"ActivateTemplate" parameters:parameters completion:completion];
}

- (void)enqueuePaymentTemplateRequestWithPath:(NSString *)path
                                   parameters:(NSDictionary *)parameters
                                   completion:(PLRCompletionBlock)completion {
    [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSArray *responseArray = responseObject[@"templates"];
            if (responseArray) {
                NSMutableArray *templates = [[NSMutableArray alloc] init];
                for (NSDictionary *templateDict in responseArray) {
                    PLRPaymentTemplate *template = [self.class paymentTemplateFromJSON:templateDict];
                    if (template) {
                        [templates addObject:template];
                    }
                }
                completion([templates copy], nil);
                return;
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                PLRPaymentTemplate *template = [self.class paymentTemplateFromJSON:responseObject];
                if (template) {
                    completion(template, nil);
                }
                return;
            }
            
            completion(nil, [self.class invalidServerResponseError]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, [self.class domainErrorFromError:error]);
        }
    }];
}

+ (PLRPaymentTemplate *)paymentTemplateFromJSON:(NSDictionary *)JSONTemplate {
    if (!JSONTemplate[kRecurrentTemplateKey]) {
        return nil;
    }
    
    PLRPaymentTemplate *template = [[PLRPaymentTemplate alloc] initWithTemplateId:JSONTemplate[kRecurrentTemplateKey]];
    template.cardHolder = JSONTemplate[@"card_holder"];
    template.cardNumber = JSONTemplate[@"card_number"];
    template.expiry = JSONTemplate[@"expiry"];
    template.active = [JSONTemplate[@"active"] boolValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    template.creationDate = [dateFormatter dateFromString:JSONTemplate[@"created"]];
    
    return template;
}

@end

@implementation PaylerAPIClient (ApplePay)

- (void)requestPayment:(PKPayment *)payment forSessionWithId:(NSString *)sessionId completion:(PLRPaymentCompletionBlock)completion {
    NSParameterAssert(payment);
    NSParameterAssert(sessionId.length);
    
    NSString *applePaymentData = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"session_id": sessionId, @"apple_payment_data": applePaymentData}];
    if ([payment respondsToSelector:@selector(shippingContact)] && payment.shippingContact.emailAddress.length) {
        parameters[@"email"] = payment.shippingContact.emailAddress;
    }
    [self enqueuePaymentRequestWithPath:@"ApplePay" parameters:[parameters copy] completion:completion];
}

@end
