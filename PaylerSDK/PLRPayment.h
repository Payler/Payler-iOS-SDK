//
//  PLRPayment.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  В классе инкапсулирована информация о платеже. 
 */
@interface PLRPayment : NSObject

/**
 *  Идентификатор оплачиваемого заказа в системе Продавца. Должен быть уникальным для каждого платежа(сессии).
 */
@property (nonatomic, readonly, copy) NSString *paymentId;

/**
 *  Сумма платежа в копейках.
 */
@property (nonatomic, readonly, assign) NSInteger amount;

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
- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount product:(NSString *)product;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSInteger)amount product:(NSString *)product total:(CGFloat)total;

- (id)init __attribute__((unavailable("Must use initWithId:amount: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithId:amount: instead.")));

@end
