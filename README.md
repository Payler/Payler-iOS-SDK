# PaylerSDK

Обертка для работы с Payler Gate API. По всем вопросам, связанным с подключением, а также для получения тестового/боевого доступа пишите нам на <24@payler.com>.


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

## Важное замечание

SDK сверяет SSL-сертификат, лежащий внутри него с SSL-сертификатом на сервере Payler.  Это
дополнительная мера безопасности, так называемый SSL-pinning.

Сертификат меняется каждый год.  По этой причине нужно быть готовым в декабре
каждого года выпустить обновление для всех приложений использующих Payler
GateAPI SDK.

## Требования
Версия 2.x PaylerSDK поддерживает iOS 7+, для работы с сетью используется AFNetworking версии 3.x. Также требуется Xcode 7+.

Версия 1.x PaylerSDK поддерживает iOS 6+, для работы с сетью используется AFNetworking версии 2.x.

## Установка

PaylerSDK доступно через [CocoaPods](http://cocoapods.org). Для установки просто добавьте следующую строчку в ваш Podfile:

    pod "PaylerSDK"

## Контакты

[Максим Павлов](https://github.com/imaks), <mp@poloniumarts.com>

## Лицензия

PaylerSDK is available under the MIT license. See the LICENSE file for more info.

