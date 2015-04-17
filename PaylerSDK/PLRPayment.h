//
//  PLRPayment.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PLRPaymentTemplate;

typedef NS_ENUM(NSUInteger, PLRPaymentStatus) {
    PLRPaymentStatusUnknown,
    PLRPaymentStatusCreated, // Платеж зарегистрирован в шлюзе, но его обработка в процессинге не начата.
    PLRPaymentStatusPreAuthorized3DS, // Пользователь начал аутентификацию по протоколу 3-D Secure, на этом операции по платежу завершились.
    PLRPaymentStatusPreAuthorizedAF, // Пользователь начал аутентификацию с помощью антифрод-сервиса, на этом операции по платежу завершились.
    PLRPaymentStatusAuthorized, // Средства заблокированы, но не списаны (двухстадийный платеж).
    PLRPaymentStatusRetrieved, // Средства на карте частично разблокированы
    PLRPaymentStatusReversed, // Средства на карте были заблокированы и разблокированы (двухстадийный платеж).
    PLRPaymentStatusCharged, // Денежные средства списаны с карты Пользователя, платёж завершен успешно.
    PLRPaymentStatusRefunded, // Успешно произведен полный или частичный возврат денежных средств на карту Пользователя
    PLRPaymentStatusRejected, // Операция по платежу отклонена
    PLRPaymentStatusError // Последняя операция по платежу завершена с ошибкой
};

/**
 *  В классе инкапсулирована информация о платеже. 
 */
@interface PLRPayment : NSObject

/**
 *  Идентификатор оплачиваемого заказа в системе Продавца. Должен быть уникальным для каждого платежа(сессии). Допускаются только печатные ASCII-символы, максимальное количество 100.
 */
@property (nonatomic, readonly, copy) NSString *paymentId;

/**
 *  Сумма платежа в копейках.
 */
@property (nonatomic, readonly, assign) NSUInteger amount;

/**
 *  Статус платежа.
 */
@property (nonatomic, readonly, assign) PLRPaymentStatus status;

/**
 *  Наименование оплачиваемого продукта. Максимальное количество символов - 100.
 */
@property (nonatomic, readonly, copy) NSString *product;

/**
 *  Количество оплачиваемых в заказе продуктов.
 */
@property (nonatomic, readonly, assign) CGFloat total;

/**
 *  Если не nil, то это шаблон рекуррентных платежей, по которому был выполнен данный платеж.
 */
@property (nonatomic, strong) NSString *recurrentTemplateId;

/**
 *  Словарь, содержащий параметры, использумые в запросах к API.
 */
- (NSDictionary *)dictionaryRepresentation;

//  Следующие методы инициализируют и возвращают объект класса PLRPayment. Параметр paymentId не должен быть nil.
- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount status:(NSString *)status;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount status:(NSString *)status product:(NSString *)product total:(CGFloat)total NS_DESIGNATED_INITIALIZER;

- (id)init __attribute__((unavailable("Must use initWithId:amount: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithId:amount: instead.")));

@end

/**
 *  В классе инкапсулирована информация о шаблоне рекуррентного платежа.
 */
@interface PLRPaymentTemplate : NSObject

/**
 *  Идентификатор шаблона рекуррентного платежа.
 */
@property (nonatomic, readonly, copy) NSString *recurrentTemplateId;

/**
 *  Дата и время регистрации шаблона рекуррентных платежей в системе Payler.
 */
@property (nonatomic, copy) NSDate *creationDate;

/**
 *  Имя держателя карты, к которой привязан шаблон.
 */
@property (nonatomic, copy) NSString *cardHolder;

/**
 *  Маскированный номер карты, к которой привязан шаблон.
 */
@property (nonatomic, copy) NSString *cardNumber;

/**
 *  Срок действия шаблона рекуррентных платежей формата "MM/yy".
 */
@property (nonatomic, copy) NSString *expiry;

/**
 *  Показывает, активен ли шаблон.
 */
@property (nonatomic, getter=isActive) BOOL active;

// Инициализирует и возвращает объект класса PLRPaymentTemplate. recurrentTemplateId не должен быть nil.
- (instancetype)initWithTemplateId:(NSString *)recurrentTemplateId;

- (id)init __attribute__((unavailable("Must use initWithTemplateId: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithTemplateId: instead.")));

@end
