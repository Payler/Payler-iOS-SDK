//
//  Payler.m
//  PaylerSDK
//
//  Created by Максим Павлов on 08.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PaylerAPIClient.h"
#import "PLRPayment.h"

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

- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Charge" payment:payment] completion:completion];
}

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Retrieve" payment:payment] completion:completion];
}

- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Refund" payment:payment] completion:completion];
}

- (void)enqueuePaymentRequest:(NSURLRequest *)request
                   completion:(PLRCompletionBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isPaymentInfoValid:responseObject]) {
                PLRPayment *payment = [[PLRPayment alloc] initWithId:responseObject[@"order_id"] amount:[responseObject[@"amount"] integerValue]];
                completion(payment, responseObject[@"info"], nil);
            } else {
                completion(nil, nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *operationError = [self.class errorFromRequestOperation:operation];
        if (completion) {
            completion(nil, nil, operationError);
        }
    }];

    [self.operationQueue addOperation:operation];
}

- (BOOL)isPaymentInfoValid:(NSDictionary *)paymentInfo {
    NSAssert([paymentInfo isKindOfClass:[NSDictionary class]], @"Invalid argument type");

    return [paymentInfo[@"order_id"] length] && paymentInfo[@"amount"];
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

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRFetchStatusCompletionBlock)completion {
    NSParameterAssert(paymentId);

    NSDictionary *parameters = @{@"key": self.merchantKey, @"order_id": paymentId};
    [self POST:@"GetStatus" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isPaymentStatusInfoValid:responseObject]) {
                PLRPayment *payment = [[PLRPayment alloc] initWithId:responseObject[@"order_id"] amount:[responseObject[@"amount"] integerValue]];
                completion(payment, responseObject[@"status"], responseObject[@"info"], nil);
            } else {
                completion(nil, nil, nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *operationError = [self.class errorFromRequestOperation:operation];
        if (completion) {
            completion(nil, nil, nil, operationError);
        }
    }];
    
}

- (BOOL)isPaymentStatusInfoValid:(NSDictionary *)paymentStatusInfo {
    return [self isPaymentInfoValid:paymentStatusInfo] && [paymentStatusInfo[@"status"] length];
}

@end
