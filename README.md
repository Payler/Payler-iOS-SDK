# PaylerSDK

Обертка для работы с Payler Gate API. По всем вопросам, связанным с подключением, а также для получения тестового/боевого доступа пишите нам на <24@payler.com>.


## Пример использования
Регистрация шаблона рекуррентных платежей

    PaylerAPIClient *client = [PaylerAPIClient clientWithMerchantKey:@"..." password:@"..."];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"paymentId" amount:10000];
    NSURL *callbackURL = [NSURL URLWithString:[@"callbackURL" stringByAppendingString:paymentId]];
    PLRSessionInfo *sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:payment callbackURL:@"callbackURL" sessionType:sessionType];
    sessionInfo.recurrent = true;
    [client startSessionWithInfo:sessionInfo completion:^(PLRPayment *payment, NSString *sessionId, NSError *error) {
        
    }];

После завершения оплаты получаем информацию о платеже, которая содержит идентификатор шаблона рекуррентных платежей
    
    __block PLRPayment *payment;
    [client fetchStatusForPaymentWithId:sessionInfo.paymentInfo.paymentId completion:^(PLRPayment *fetchPayment, NSError *error) {
        payment = fetchPayment;
    }];
    
Используя этот идентификатор можно совершать рекуррентные платежи
    
    [self.client repeatPayment:payment completion:^(PLRPayment *fetchedPayment, NSError *error) {
        
    }];
    
Так же используя этот идентификатор можно получить сам шаблон рекуррентных платежей

    __block PLRPaymentTemplate *template;
    [self.client fetchTemplateWithId:payment.recurrentTemplate.recurrentTemplateId completion:^(PLRPaymentTemplate *fetchedTemplate, NSError *error) {
        template = fetchedTemplate;
    }];

Возврат средств на карту покупателя

    [client refundPayment:payment completion:^(PLRPayment *payment, NSDictionary *info, NSError *error) {
        if (!error) {
            NSLog(@"Refund completed");
        } else {
            NSLog(@"Error: %@", error);
        }
    }];


Скачайте тестовый проект, чтобы посмотреть больше примеров.

## Требования
Для работы PaylerSDK требуется iOS 6.0 и выше.

## Установка

PaylerSDK доступно через [CocoaPods](http://cocoapods.org). Для установки просто добавьте следующую строчку в ваш Podfile:

    pod "PaylerSDK"

## Контакты

[Максим Павлов](https://github.com/imaks), <mp@poloniumarts.com>

## Лицензия

PaylerSDK is available under the MIT license. See the LICENSE file for more info.

