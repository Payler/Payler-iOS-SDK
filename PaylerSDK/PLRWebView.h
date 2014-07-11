//
//  PLRWebView.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLRSessionInfo, PaylerAPIClient, PLRPayment;

typedef void(^PLRPayBlock)(PLRPayment *payment, NSError *error);

/**
 *  Наследник класса UIWebView, в котором инкапсулирована логика оплаты через страницу шлюза Payler.
 */
@interface PLRWebView : UIWebView

// Свойства, используемые для выполнения запроса старта сессии, необходимого для проведения платежа.
@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PaylerAPIClient *client;

/**
 *  Запрос с перенаправлением Пользователя на страницу шлюза для выполнения одностадийного платежа или блокировки средств на карте Пользователя при двухстадийном платеже. При вызове этого метода свойства класса sessionInfo и client не должны быть nil.
 *
 *  @param completion Блок вызывается либо после получения результатов оплаты(в этом случае параметр payment содержит paymentId, amount и status, а error равен nil), либо при возникновении ошибки при оплате(в этом случае параметр payment равен nil, а error содержит информацию об ошибке).
 *
 */
- (void)payWithCompletion:(PLRPayBlock)completion;

@end
