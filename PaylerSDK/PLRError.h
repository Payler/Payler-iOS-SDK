//
//  PLRError.h
//  PaylerSDK
//
//  Created by Максим Павлов on 13.01.15.
//  Copyright (c) 2015 Polonium Arts. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN
extern NSString *const PaylerErrorDomain;

typedef NS_ENUM (NSUInteger, PaylerErrorCode) {
    PaylerErrorNone,
    PaylerErrorInvalidAmount,
    PaylerErrorBalanceExceeded,
    PaylerErrorDuplicateOrderId,
    PaylerErrorIssuerDeclinedOperation,
    PaylerErrorLimitExceded,
    PaylerErrorAFDeclined,
    PaylerErrorInvalidOrderState,
    PaylerErrorMerchantDeclined,
    PaylerErrorOrderNotFound,
    PaylerErrorProcessingError,
    PaylerErrorPartialRetrieveNotAllowed,
    PaylerErrorRefundNotAllowed,
    PaylerErrorGateDeclined,
    PaylerErrorInvalidCardInfo,
    PaylerErrorInvalidCardPan,
    PaylerErrorInvalidCardholder,
    PaylerErrorInvalidPayInfo,
    PaylerErrorAPINotAllowed,
    PaylerErrorAccessDenied,
    PaylerErrorInvalidParams,
    PaylerErrorSessionTimeout,
    PaylerErrorMerchantNotFound,
    PaylerErrorUnexpectedError
};

extern NSString* PaylerErrorDescriptionFromCode(PaylerErrorCode errorCode);

NS_ASSUME_NONNULL_END