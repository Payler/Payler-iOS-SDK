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
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self.requestSerializer requestWithMethod:@"POST"
                                           URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString]
                                          parameters:parameters
                                               error:nil];
}

#pragma mark - Error handling

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation {
	NSParameterAssert(operation);

	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    PaylerErrorCode errorCode = [[operation.responseObject valueForKeyPath:@"error.code"] integerValue];
    userInfo[NSLocalizedDescriptionKey] = PaylerErrorDescriptionFromCode(errorCode);
	if (operation.error) userInfo[NSUnderlyingErrorKey] = operation.error;
	return [NSError errorWithDomain:PaylerErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)invalidParametersError {
    return [NSError errorWithDomain:PaylerErrorDomain
                               code:PaylerErrorInvalidParams
                           userInfo:@{NSLocalizedDescriptionKey: PaylerErrorDescriptionFromCode(PaylerErrorInvalidParams)}];
}

@end

@implementation PaylerAPIClient (Payments)

- (void)startSessionWithInfo:(PLRSessionInfo *)sessionInfo completion:(PLRStartSessionCompletionBlock)completion {
    NSParameterAssert(sessionInfo);

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    [parameters addEntriesFromDictionary:[sessionInfo dictionaryRepresentation]];

    [self POST:@"StartSession" parameters:[parameters copy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isStartSessionInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], responseObject[@"session_id"], nil);
            } else {
                completion(nil, nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, nil, [self.class errorFromRequestOperation:operation]);
        }
    }];
}

- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Charge" payment:payment] completion:completion];
}

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Retrieve" payment:payment] completion:completion];
}

- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Refund" payment:payment] completion:completion];
}

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRCompletionBlock)completion {
    NSParameterAssert(paymentId);

    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:0];
    [self enqueuePaymentRequest:[self requestWithPath:@"GetStatus" parameters:[self parametersWithPayment:payment includePassword:NO includeAmount:NO]] completion:completion];
}

#pragma mark - Private methods

- (void)enqueuePaymentRequest:(NSURLRequest *)request
                   completion:(PLRCompletionBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isPaymentInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], nil);
            } else {
                completion(nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, [self.class errorFromRequestOperation:operation]);
        }
    }];

    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)paymentRequestWithPath:(NSString *)path payment:(PLRPayment *)payment {
    NSParameterAssert(payment);
    
    return [self requestWithPath:path parameters:[self parametersWithPayment:payment includePassword:YES includeAmount:YES]];
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
        PLRPaymentTemplate *template = [[PLRPaymentTemplate alloc] initWithTemplateId:JSONPayment[kRecurrentTemplateKey]];
        payment.recurrentTemplate = template;
    }
    return payment;
}

@end

@implementation PaylerAPIClient (RecurrentPayments)

- (void)repeatPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    NSParameterAssert(payment);
    NSParameterAssert(payment.recurrentTemplate);
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self parametersWithPayment:payment includePassword:NO includeAmount:YES]];
    parameters[kRecurrentTemplateKey] = payment.recurrentTemplate.recurrentTemplateId;
    [self enqueuePaymentRequest:[self requestWithPath:@"RepeatPay" parameters:[parameters copy]] completion:completion];
}

- (void)fetchTemplateWithId:(NSString *)recurrentTemplateId completion:(PLRPaymentTemplateBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    if (recurrentTemplateId) {
        parameters[kRecurrentTemplateKey] = recurrentTemplateId;
    }
    
    [self enqueuePaymentTemplateRequest:[self requestWithPath:@"GetTemplate" parameters:[parameters copy]] completion:completion];
}

- (void)activateTemplateWithId:(NSString *)recurrentTemplateId active:(BOOL)active completion:(PLRPaymentTemplateBlock)completion {
    NSParameterAssert(recurrentTemplateId);
    
    NSDictionary *parameters = @{@"key": self.merchantKey, kRecurrentTemplateKey: recurrentTemplateId, @"active": active ? @"true": @"false"};
    [self enqueuePaymentTemplateRequest:[self requestWithPath:@"ActivateTemplate" parameters:parameters] completion:completion];
}

- (void)enqueuePaymentTemplateRequest:(NSURLRequest *)request
                           completion:(PLRPaymentTemplateBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSMutableArray *templates = [[NSMutableArray alloc] init];
                for (NSDictionary *templateDict in responseObject) {
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
            
            completion(nil, [self.class invalidParametersError]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, [self.class errorFromRequestOperation:operation]);
        }
    }];
    
    [self.operationQueue addOperation:operation];
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
