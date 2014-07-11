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
@class PLRSessionInfo;

typedef void(^PLRStartSessionCompletionBlock)(PLRPayment *payment, NSString *sessionId, NSDictionary *info, NSError *error);
typedef void(^PLRPaymentCompletionBlock)(PLRPayment *payment, NSDictionary *info, NSError *error);
typedef void(^PLRFetchPaymentStatusCompletionBlock)(PLRPayment *payment, NSString *status, NSDictionary *info, NSError *error);

/**
 *  В классе инкапсулированы запросы и логика работы с Payler Gate API.
 */
@interface PaylerAPIClient : AFHTTPRequestOperationManager

/**
 *  Инициализирует и возвращает объект класса PaylerAPIClient с соответствующими идентификатором и паролем Продавца. Если один из параметров nil, то запросы выполняются к тестовому серверу.
 *
 *  @param merchantKey      Идентификатор Продавца.
 *  @param merchantPassword Пароль Продавца для проведения операций через Gate API.
 */
- (instancetype)initWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword;

@end

/**
 *   Для запросов "Charge", "Retrieve", "Refund", если запрос выполнился успешно, то параметры payment и info в блоке содержат информацию о платеже, а error равен nil. Если запрос выполнился неудачно, то payment и info равны nil, а error содержит информацию об ошибке.
 */
@interface PaylerAPIClient (Requests)

/**
 *  Запрос инициализации сессии платежа. Обязательно выполняется перед операциями списания или блокировки средств на карте Пользователя.
 *
 *  @param sessionInfo Объект класса PLRSessionInfo. Не должен быть nil.
 *  @param completion  Блок выполняется после завершения запроса. Если запрос выполнился успешно, то параметры payment, sessionId и info в блоке содержат информацию о сессии, а error равен nil. Если запрос выполнился неудачно, то payment, sessionId и info равны nil, а error содержит информацию об ошибке.
 */
- (void)startSessionWithInfo:(PLRSessionInfo *)sessionInfo completion:(PLRStartSessionCompletionBlock)completion;

/**
 *  Запрос списания средств, заблокированных на карте Пользователя в рамках двухстадийного платежа. Статус платежа должен быть Authorized.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит списанная сумма в копейках. 
 */
- (void)chargePayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion;

/**
 *  Запрос полной или частичной отмены блокировки средств, заблокированных на карте Пользователя в рамках двухстадийного платежа. Статус платежа должен быть Authorized.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит новая величина суммы платежа в копейках.
 */
- (void)retrievePayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion;

/**
 *  Запрос полного или частичного возврата средств на карту Пользователя, списанных в ходе одностадийного или двухстадийного платежей. Статус платежа должен быть Charged.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит остаток списанной суммы в копейках.
 */
- (void)refundPayment:(PLRPayment *)payment completion:(PLRPaymentCompletionBlock)completion;

/**
 *  Запрос получения статуса платежа.
 *
 *  @param paymentId  Идентификатор заказа в системе Продавца.
 *  @param completion Блок выполняется после завершения запроса. Если запрос выполнился успешно, то параметры payment, status и info в блоке содержат информацию о платеже, а error равен nil. Если запрос выполнился неудачно, то payment, status и info равны nil, а error содержит информацию об ошибке.
 */
- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRFetchPaymentStatusCompletionBlock)completion;

@end

extern NSString *const PaylerErrorDomain;
