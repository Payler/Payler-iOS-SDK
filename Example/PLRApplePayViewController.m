//
//  PLRApplePayViewController.m
//  PaylerSDK
//
//  Created by Maxim Pavlov on 30.01.17.
//  Copyright © 2017 Polonium Arts. All rights reserved.
//

#import "PLRApplePayViewController.h"

#import <PassKit/PassKit.h>

#import "PaylerAPIClient.h"
#import "PLRSessionInfo.h"
#import "PLRPayment.h"

@interface PLRApplePayViewController ()<PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic, strong) PaylerAPIClient *client;
@end

@implementation PLRApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#warning Здесь нужно указать ваши параметры.
    self.client = [PaylerAPIClient testClientWithMerchantKey:@"<#Merchant Key#>" password:@"<#Merchant password#>"];
    
    [self setupApplePayButton];
}

- (void)payButtonPressed:(PKPaymentButton *)sender {
    PKPaymentRequest *request = [PKPaymentRequest new];
    request.supportedNetworks = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
    request.countryCode = @"RU";
    request.currencyCode = @"RUB";
    
    #warning Укажите ваш merchant identifier
    request.merchantIdentifier = @"<#Merchant identifier from your entitlements#>";
    request.merchantCapabilities = PKMerchantCapabilityDebit | PKMerchantCapabilityCredit | PKMerchantCapability3DS;
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:@"Test payment" amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]]];
    request.requiredShippingAddressFields = PKAddressFieldName | PKAddressFieldEmail;
    
    PKPaymentAuthorizationViewController *controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [self.client requestPayment:payment forSessionWithId:@"<#Session id#>" completion:^(PLRPayment * _Nullable payment, NSError * _Nullable error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
        } else {
            completion(PKPaymentAuthorizationStatusSuccess);
        }
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)setupApplePayButton {
    NSArray *paymentNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    if ([PKPaymentAuthorizationController canMakePaymentsUsingNetworks:paymentNetworks]) {
        PKPaymentButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self action:@selector(payButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [button.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    }
}

@end
