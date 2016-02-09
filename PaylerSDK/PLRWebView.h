//
//  PLRWebView.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLRSessionInfo, PaylerAPIClient, PLRPayment, PLRWebView;

@protocol PLRWebViewDataSource <NSObject>

// Используются для выполнения запроса старта сессии, необходимого для проведения платежа.
- (PLRSessionInfo *)webViewSessionInfo:(PLRWebView *)sender;
- (PaylerAPIClient *)webViewClient:(PLRWebView *)sender;

@end

typedef void (^PLRPayBlock)( PLRPayment * _Nullable payment,  NSError * _Nullable error);

/**
 *  Наследник класса UIWebView, в котором инкапсулирована логика оплаты через страницу шлюза Payler.
 */
@interface PLRWebView : UIWebView

@property (nonatomic, weak) id<PLRWebViewDataSource> dataSource;

/**
 *  Запрос с перенаправлением Пользователя на страницу шлюза для выполнения одностадийного платежа или блокировки средств на карте Пользователя при двухстадийном платеже.
 *
 *  @param completion Блок вызывается либо после получения результатов оплаты (в этом случае параметр payment содержит paymentId, amount и status, а error равен nil), либо при возникновении ошибки при оплате (в этом случае параметр payment равен nil, а error содержит информацию об ошибке).
 *
 */
- (void)payWithCompletion:(PLRPayBlock)completion;

/**
 *  Инициализирует и возвращает объект класса PLRWebView с объектом dataSource, реализующим протокол PLRWebViewDataSource.
 *  
 *  @warning dataSource не должен быть nil.
 */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<PLRWebViewDataSource>)dataSource;

@end

NS_ASSUME_NONNULL_END