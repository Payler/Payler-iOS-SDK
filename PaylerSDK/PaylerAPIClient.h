//
//  Payler.h
//  PaylerSDK
//
//  Created by Максим Павлов on 08.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@class PLRPayment, PLRSessionInfo, PLRPaymentTemplate;

typedef void (^PLRStartSessionCompletionBlock)(PLRPayment * _Nullable payment, NSString * _Nullable sessionId, NSError * _Nullable error);
typedef void (^PLRCompletionBlock)(id _Nullable object, NSError * _Nullable error);
typedef void (^PLRPaymentCompletionBlock)(PLRPayment * _Nullable payment, NSError * _Nullable error);

/**
 *  В классе инкапсулированы запросы и логика работы с Payler Gate API.
 */
@interface PaylerAPIClient : AFHTTPSessionManager

/**
 *  Инициализирует и возвращает объект класса PaylerAPIClient с соответствующими параметрами боевого доступа.
 *
 *  @param merchantKey      Идентификатор Продавца. Не должен быть nil.
 *  @param merchantPassword Пароль Продавца для проведения операций через Gate API. Не должен быть nil.
 */
+ (instancetype)clientWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword;

/**
 *  Инициализирует и возвращает объект класса PaylerAPIClient с соответствующими параметрами тестового доступа.
 *
 *  @param merchantKey      Идентификатор Продавца для тестового доступа. Не должен быть nil.
 *  @param merchantPassword Пароль Продавца для тестового доступа. Не должен быть nil.
 */
+ (instancetype)testClientWithMerchantKey:(NSString *)merchantKey password:(NSString *)merchantPassword;

- (id)init __attribute__((unavailable("Must use clientWithMerchantKey:password: or testClientWithMerchantKey:password: instead.")));
+ (id)new __attribute__((unavailable("Must use clientWithMerchantKey:password: or testClientWithMerchantKey:password: instead.")));

@end

/**
 *   Если запрос выполнился успешно, то параметр payment в блоке содержит информацию о платеже, а error равен nil. Если запрос выполнился неудачно, то payment равен nil, а error содержит информацию об ошибке.
 */
@interface PaylerAPIClient (Payments)

/**
 *  Запрос инициализации сессии платежа. Обязательно выполняется перед операциями списания или блокировки средств на карте Пользователя.
 *
 *  @param sessionInfo Объект класса PLRSessionInfo. Не должен быть nil.
 *  @param completion  Блок выполняется после завершения запроса. sessionId - идентификатор платежа в системе Payler.
 */
- (void)startSessionWithInfo:(PLRSessionInfo *)sessionInfo completion:(PLRStartSessionCompletionBlock)completion;

/**
 *  Запрос поиска платёжной сессии по идентификатору платежа.
 *
 *  @param paymentId  Идентификатор оплачиваемого заказа в системе Продавца.
 *  @param completion Блок выполняется после завершения запроса. В параметре object - объект класса NSDictionary.
 */
- (void)fetchSessionInfoWithPaymentId:(NSString *)paymentId completion:(PLRCompletionBlock)completion;

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
 *  @param completion Блок выполняется после завершения запроса. В поле status параметра payment приходит текущий статус платежа.
 */
- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRPaymentCompletionBlock)completion;

@end

@interface PaylerAPIClient (RecurrentPayments)

/**
 *  Запрос осуществления повторного платежа в рамках серии рекуррентных платежей.
 *
 *  @param payment    Объект класса PLRPayment. Сам объект и его свойство recurrentTemplate не должны быть nil.
 *  @param completion Блок выполняется после завершения запроса.
 */
- (void)repeatPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос получения информации о шаблоне рекуррентных платежей.
 *
 *  @param recurrentTemplateId Идентификатор шаблона рекуррентных платежей.
 *  @param completion          Блок выполняется после завершения запроса. Если recurrentTemplateId == nil, то в параметре object блока придет массив всех зарегистрированных на Продавца шаблонов, иначе объект PLRPaymentTemplate.
 */
- (void)fetchTemplateWithId:(NSString *)recurrentTemplateId completion:(PLRCompletionBlock)completion;

/**
 *  Запрос активации/деактивации шаблона рекуррентных платежей.
 *
 *  @param recurrentTemplateId Идентификатор шаблона рекуррентных платежей. Не должен быть nil.
 *  @param active              Показывает, требуется ли активировать или деактивировать шаблон рекуррентных платежей.
 *  @param completion          Блок выполняется после завершения запроса. В параметре object - объект класса PLRPaymentTemplate.
 */
- (void)activateTemplateWithId:(NSString *)recurrentTemplateId active:(BOOL)active completion:(PLRCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
