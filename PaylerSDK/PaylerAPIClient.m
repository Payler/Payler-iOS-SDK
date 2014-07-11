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

NSString *const PaylerErrorDomain = @"com.poloniumarts.PaylerSDK.error";

typedef NS_ENUM(NSUInteger, PaylerErrorCode) {
    PaylerErrorNone,
    PaylerErrorInvalidAmount,
    PaylerErrorBalanceExceeded,
    PaylerErrorDuplicateOrderId,
    PaylerErrorIssuerDeclinedOperation,
    PaylerErrorLimitExceded,
    PaylerErrorAFDeclined,
    PaylerErrorInvalidOrderState,
    PaylerErrorMerchantDeclined,
    PaylerErrorOrderNotFound,
    PaylerErrorProcessingError,
    PaylerErrorPartialRetrieveNotAllowed,
    PaylerErrorRefundNotAllowed,
    PaylerErrorGateDeclined,
    PaylerErrorInvalidCardInfo,
    PaylerErrorInvalidCardPan,
    PaylerErrorInvalidCardholder,
    PaylerErrorInvalidPayInfo,
    PaylerErrorAPINotAllowed,
    PaylerErrorAccessDenied,
    PaylerErrorInvalidParams,
    PaylerErrorSessionTimeout,
    PaylerErrorMerchantNotFound,
    PaylerErrorUnexpectedError
};

NSString *const PaylerErrorDescriptionFromCode[] = {
    [PaylerErrorNone] = @"",
    [PaylerErrorInvalidAmount] = @"Неверно указана сумма транзакции",
    [PaylerErrorBalanceExceeded] = @"Превышен баланс",
    [PaylerErrorDuplicateOrderId] = @"Заказ с таким order_id уже регистрировали",
    [PaylerErrorIssuerDeclinedOperation] = @"Эмитент карты отказал в операции",
    [PaylerErrorLimitExceded] = @"Превышен лимит",
    [PaylerErrorAFDeclined] = @"Транзакция отклонена АнтиФрод механизмом",
    [PaylerErrorInvalidOrderState] = @"Попытка выполнения транзакции для недопустимого состояния платежа",
    [PaylerErrorMerchantDeclined] = @"Превышен лимит магазина или транзакции запрещены Магазину",
    [PaylerErrorOrderNotFound] = @"Платёж с указанным order_id не найден",
    [PaylerErrorProcessingError] = @"Ошибка при взаимодействии с процессинговым центром",
    [PaylerErrorPartialRetrieveNotAllowed] = @"Изменение суммы авторизации не может быть выполнено",
    [PaylerErrorRefundNotAllowed] = @"Возврат не может быть выполнен",
    [PaylerErrorGateDeclined] = @"Отказ шлюза в выполнении транзакции",
    [PaylerErrorInvalidCardInfo] = @"Введены неправильные параметры карты",
    [PaylerErrorInvalidCardPan] = @"Неверный номер карты",
    [PaylerErrorInvalidCardholder] = @"Недопустимое имя держателя карты",
    [PaylerErrorInvalidPayInfo] = @"Некорректный параметр PayInfo (неправильно сформирован или нарушена крипта)",
    [PaylerErrorAPINotAllowed] = @"Данное API не разрешено к использованию",
    [PaylerErrorAccessDenied] = @"Доступ с текущего IP или по указанным параметрам запрещен",
    [PaylerErrorInvalidParams] = @"Неверный набор или формат параметров",
    [PaylerErrorSessionTimeout] = @"Время платежа истекло",
    [PaylerErrorMerchantNotFound] = @"Описание продавца не найдено",
    [PaylerErrorUnexpectedError] = @"Непредвиденная ошибка"
};

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
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    }
    return self;
}

#pragma mark - Error handling

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation {
	NSParameterAssert(operation);

	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    PaylerErrorCode errorCode = [[operation.responseObject valueForKeyPath:@"error.code"] integerValue];
    userInfo[NSLocalizedDescriptionKey] = PaylerErrorDescriptionFromCode[errorCode];
	if (operation.error) userInfo[NSUnderlyingErrorKey] = operation.error;
	return [NSError errorWithDomain:PaylerErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)invalidParametersError {
    return [NSError errorWithDomain:PaylerErrorDomain
                               code:PaylerErrorInvalidParams
                           userInfo:@{NSLocalizedDescriptionKey: PaylerErrorDescriptionFromCode[PaylerErrorInvalidParams]}];
}

@end

@implementation PaylerAPIClient (Requests)

- (void)startSessionWithInfo:(PLRSessionInfo *)sessionInfo completion:(PLRStartSessionCompletionBlock)completion {
    NSParameterAssert(sessionInfo);

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    [parameters addEntriesFromDictionary:[sessionInfo dictionaryRepresentation]];

    [self POST:@"StartSession" parameters:[parameters copy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isStartSessionInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], responseObject[@"session_id"], responseObject[@"info"], nil);
            } else {
                completion(nil, nil, nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, nil, nil, [self.class errorFromRequestOperation:operation]);
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

    NSDictionary *parameters = @{@"key": self.merchantKey, @"order_id": paymentId};
    NSString *URLString = [[NSURL URLWithString:@"GetStatus" relativeToURL:self.baseURL] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    [self enqueuePaymentRequest:request completion:completion];
}

#pragma mark - Private methods

- (void)enqueuePaymentRequest:(NSURLRequest *)request
                   completion:(PLRCompletionBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isPaymentInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], responseObject[@"info"], nil);
            } else {
                completion(nil, nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, nil, [self.class errorFromRequestOperation:operation]);
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

- (BOOL)isStartSessionInfoValid:(NSDictionary *)startSessionInfo {
    return [self isPaymentInfoValid:startSessionInfo] && [startSessionInfo[@"session_id"] length];
}

- (BOOL)isPaymentInfoValid:(NSDictionary *)paymentInfo {
    NSAssert([paymentInfo isKindOfClass:[NSDictionary class]], @"Invalid argument type");

    return [paymentInfo[@"order_id"] length] && (paymentInfo[@"amount"] || paymentInfo[@"new_amount"]);
}

+ (PLRPayment *)paymentFromJSON:(NSDictionary *)JSONPayment {
    NSInteger amount = [(JSONPayment[@"amount"] ?: JSONPayment[@"new_amount"]) integerValue];
    return [[PLRPayment alloc] initWithId:JSONPayment[@"order_id"] amount:amount status:JSONPayment[@"status"]];
}

@end
