//
//  PLRWebView.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLRSessionInfo;
@class PaylerAPIClient;

typedef void(^PLRPayBlock)(BOOL success, NSError *error);

/**
 *  Наследник класса UIWebView, в котором инкапсулирована логика оплаты через страницу шлюза Payler.
 */
@interface PLRWebView : UIWebView

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PaylerAPIClient *client;

/**
 *  Запрос списания средств с перенаправлением пользователя на страницу шлюза. Результатом обработки запроса является списание денежных средств при одностадийной схеме проведения платежа, либо блокировка средств на карте Пользователя при двухстадийной схеме проведения платежа.
 *
 *  @param completion Блок вызывается после завершения оплаты.
 */
- (void)payWithCompletion:(PLRPayBlock)completion;

/**
 *  Инициализирует и возвращает объект класса PLRWebView.
 */
- (instancetype)initWithFrame:(CGRect)frame client:(PaylerAPIClient *)client sessionInfo:(PLRSessionInfo *)sessionInfo;

@end
