//
//  PLRSessionInfo.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLRPayment;

typedef NS_ENUM(NSUInteger, PLRSessionType) {
    PLRSessionTypeOneStep, // одностадийный платеж
    PLRSessionTypeTwoStep  // двухстадийный платеж
};

/**
 *  В классе инкапсулирована информация, необходимая для отправки запроса инициализации сессии платежа.
 */
@interface PLRSessionInfo : NSObject

/**
 *  Содержит данные о платеже, необходимые для инициализации сессии платежа.
 */
@property (nonatomic, readonly, strong) PLRPayment *paymentInfo;

/**
 *  Адрес возврата Пользователя после успешного выполнения платежа. Указывается Продавцом заранее при подписании договора.
 */
@property (nonatomic, readonly, copy) NSURL *callbackURL;

/**
 *  Тип сессии. Определяет количество стадий платежа. По умолчанию одностадийный.
 */
@property (nonatomic, readonly, assign) PLRSessionType sessionType;

/**
 *  Название шаблона страницы оплаты, используемого продавцом. При отсутствии используется шаблон mobile.
 */
@property (nonatomic, nullable, readonly, copy) NSString *templateName;

/**
 *  Необязательный параметр, определяющий язык страницы оплаты("en" - английский язык, "ru" - русский язык).
 */
@property (nonatomic, nullable, readonly, copy) NSString *language;

/**
 *  Показывает, требуется ли создать шаблон рекуррентных платежей на основе текущего.
 */
@property (nonatomic, getter=isRecurrent) BOOL recurrent;

/**
 *  Словарь, содержащий параметры запроса инициализации сессии платежа.
 */
- (NSDictionary *)dictionaryRepresentation;

//  Следующие методы инициализируют и возвращают объект класса PLRSessionInfo. Параметры paymentInfo и URL не должен быть nil.
- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo callbackURL:(NSURL *)URL;
- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo callbackURL:(NSURL *)URL sessionType:(PLRSessionType)sessionType;
- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo callbackURL:(NSURL *)URL sessionType:(PLRSessionType)sessionType template:(nullable NSString *)templateName language:(nullable NSString *)language NS_DESIGNATED_INITIALIZER;

- (id)init __attribute__((unavailable("Must use initWithPaymentInfo: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithPaymentInfo: instead.")));

@end

NS_ASSUME_NONNULL_END