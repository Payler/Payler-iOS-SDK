//
//  PLRPayment.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PLRPayment : NSObject

/**
 *  Идентификатор оплачиваемого заказа в системе Продавца. Должен быть уникальным для каждого платежа(сессии).
 */
@property (nonatomic, readonly, assign) NSInteger paymentId;

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

- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount;
- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount product:(NSString *)product;
- (instancetype)initWithId:(NSInteger)paymentId amount:(NSInteger)amount product:(NSString *)product total:(CGFloat)total;

@end
