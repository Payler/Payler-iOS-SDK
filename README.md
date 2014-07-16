# PaylerSDK

Обертка для работы с Payler Gate API. Для получения тестового/боевого доступа напишите нам на 24@payler.com"


## Пример использования

    PaylerAPIClient *client = [PaylerAPIClient clientWithMerchantKey:@"..." password:@"..."];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"paymentId" amount:10000];
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

Максим Павлов, <mp@poloniumarts.com>

## Лицензия

PaylerSDK is available under the MIT license. See the LICENSE file for more info.

