//
//  PLRError.m
//  PaylerSDK
//
//  Created by Максим Павлов on 13.01.15.
//  Copyright (c) 2015 Polonium Arts. All rights reserved.
//

#import "PLRError.h"

NSString *const PaylerErrorDomain = @"com.poloniumarts.PaylerSDK.error";

NSString* PaylerErrorDescriptionFromCode(PaylerErrorCode errorCode) {
    static dispatch_once_t onceToken;
    static NSDictionary *errorsDict;
    dispatch_once(&onceToken, ^{
        errorsDict =  @{@(PaylerErrorNone) : @"",
                        @(PaylerErrorInvalidAmount): @"Неверно указана сумма транзакции",
                        @(PaylerErrorBalanceExceeded): @"Превышен баланс",
                        @(PaylerErrorDuplicateOrderId): @"Заказ с таким order_id уже регистрировали",
                        @(PaylerErrorIssuerDeclinedOperation): @"Эмитент карты отказал в операции",
                        @(PaylerErrorLimitExceded): @"Превышен лимит",
                        @(PaylerErrorAFDeclined): @"Транзакция отклонена АнтиФрод механизмом",
                        @(PaylerErrorInvalidOrderState): @"Попытка выполнения транзакции для недопустимого состояния платежа",
                        @(PaylerErrorMerchantDeclined): @"Превышен лимит магазина или транзакции запрещены Магазину",
                        @(PaylerErrorOrderNotFound): @"Платёж с указанным order_id не найден",
                        @(PaylerErrorProcessingError): @"Ошибка при взаимодействии с процессинговым центром",
                        @(PaylerErrorPartialRetrieveNotAllowed): @"Изменение суммы авторизации не может быть выполнено",
                        @(PaylerErrorRefundNotAllowed): @"Возврат не может быть выполнен",
                        @(PaylerErrorGateDeclined): @"Отказ шлюза в выполнении транзакции",
                        @(PaylerErrorInvalidCardInfo): @"Введены неправильные параметры карты",
                        @(PaylerErrorInvalidCardPan): @"Неверный номер карты",
                        @(PaylerErrorInvalidCardholder): @"Недопустимое имя держателя карты",
                        @(PaylerErrorInvalidPayInfo): @"Некорректный параметр PayInfo (неправильно сформирован или нарушена крипта)",
                        @(PaylerErrorAPINotAllowed): @"Данное API не разрешено к использованию",
                        @(PaylerErrorAccessDenied): @"Доступ с текущего IP или по указанным параметрам запрещен",
                        @(PaylerErrorInvalidParams): @"Неверный набор или формат параметров",
                        @(PaylerErrorSessionTimeout): @"Время платежа истекло",
                        @(PaylerErrorMerchantNotFound): @"Описание продавца не найдено",
                        @(PaylerErrorUnexpectedError): @"Непредвиденная ошибка"};
    });
    
    return errorsDict[@(errorCode)] ?: errorsDict[@(PaylerErrorUnexpectedError)];
};