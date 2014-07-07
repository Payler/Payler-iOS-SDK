//
//  PLRSessionInfo.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLRPayment;

typedef NS_ENUM(NSUInteger, PLRSessionType) {
    PLRSessionTypeOneStep, // одностадийный платеж
    PLRSessionTypeTwoStep  // двухстадийный платеж
};

/**
 *  Содержит информацию, необходимую для отправки запроса инициализации сессии.
 */
@interface PLRSessionInfo : NSObject

/**
 *  Содержит параметры платежа, необходимые для инициализации сессии.
 */
@property (nonatomic, readonly, strong) PLRPayment *paymentInfo;

/**
 *  Тип сессии. Определяет количество стадий платежа. По умолчанию одностадийный.
 */
@property (nonatomic, readonly, assign) PLRSessionType sessionType;

/**
 *  Название шаблона страницы оплаты, используемого продавцом. При отсутствии используется шаблон по умолчанию.
 */
@property (nonatomic, readonly, copy) NSString *templateName;

/**
 *  Необязательный параметр, определяющий язык страницы оплаты("en" - английский язык, "ru" - русский язык).
 */
@property (nonatomic, readonly, copy) NSString *language;

- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo;
- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo sessionType:(PLRSessionType)sessionType;
- (instancetype)initWithPaymentInfo:(PLRPayment *)paymentInfo sessionType:(PLRSessionType)sessionType template:(NSString *)templateName language:(NSString *)language;

@end
