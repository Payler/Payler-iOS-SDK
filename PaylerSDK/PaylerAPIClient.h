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
 *  Запрос выполняется после успешной команды Pay при двухстадийной схеме проведения платежа, статус платежа должен быть Authorized. Результатом обработки запроса является списание заблокированных средств с карты Пользователя.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса.
 */
- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос выполняется после успешной команды Pay при двухстадийной схеме проведения платежа, статус платежа должен быть Authorized. Результатом обработки запроса является разблокировка(частичная или полная) денежных средств на карте Пользователя.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса.
 */
- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос выполняется после успешной команды Pay при одностадийной схеме проведения платежа или после успешной команды Charge при двухстадийной схеме проведения платежа. Статус транзакции должен быть Charged. Результатом запроса является возврат списанных ранее денежных средств на карту Пользователя.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса.
 */
- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Результатом выполнения запроса является получение актуального статуса платежа. Рекомендуется использовать в случае неполучения ответа от шлюза Payler при проведении других запросов по платежу.
 *
 *  @param paymentId  Идентификатор заказа в системе Продавца.
 *  @param completion Блок выполняется после завершения запроса. Если запрос выполнился успешно, то параметры payment, status и info в блоке содержат информацию о платеже, а error равен nil. Если запрос выполнился неудачно, то payment, status и info равны nil, а error содержит информацию об ошибке.
 */
- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRFetchStatusCompletionBlock)completion;

@end

extern NSString *const PaylerErrorDomain;
