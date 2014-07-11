//
//  PLRPayment.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
 *  Идентификатор оплачиваемого заказа в системе Продавца. Должен быть уникальным для каждого платежа(сессии). Допускаются только печатные ASCII-символы, максимальное количество 50.
 */
@property (nonatomic, readonly, copy) NSString *paymentId;

/**
 *  Сумма платежа в копейках.
 */
@property (nonatomic, readonly, assign) NSInteger amount;

/**
 *  Статус платежа.
 */
@property (nonatomic, readonly, assign) PLRPaymentStatus status;

/**
 *  Наименование оплачиваемого продукта.
 */
@property (nonatomic, readonly, copy) NSString *product;

/**
 *  Количество оплачиваемых в заказе продуктов.
 */
@property (nonatomic, readonly, assign) CGFloat total;

/**
 *  Словарь, содержащий параметры, использумые в запросах к API.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 *  Следующие методы инициализируют и возвращают объект класса PLRPayment. Параметр paymentId не должен быть nil.
 */
- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount status:(NSString *)status;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount status:(NSString *)status product:(NSString *)product total:(CGFloat)total;

- (id)init __attribute__((unavailable("Must use initWithId:amount: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithId:amount: instead.")));

@end
