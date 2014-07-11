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

typedef void(^PLRPayBlock)(BOOL completed, NSError *error);

/**
 *  Наследник класса UIWebView, в котором инкапсулирована логика оплаты через страницу шлюза Payler.
 */
@interface PLRWebView : UIWebView

/**
 *  Свойства, используемые для выполнения запроса старта сессии, необходимого для проведения платежа.
 */
@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PaylerAPIClient *client;

/**
 *  Запрос с перенаправлением Пользователя на страницу шлюза для выполнения одностадийного платежа или блокировки средств на карте Пользователя при двухстадийном платеже. При вызове этого метода свойства класса sessionInfo и client не должны быть nil.
 *
 *  @param completion Блок вызывается либо после завершения оплаты(в этом случае параметр completed равен YES, а error равен nil), либо при возникновении ошибки при оплате(в этом случае параметр completed равен NO, а error содержит информацию об ошибке).
 *
 *  @warning Для получения результатов транзакции следует использовать данные, полученные в рамках запроса статуса транзакции @see PaylerAPIClient
 */
- (void)payWithCompletion:(PLRPayBlock)completion;

@end
