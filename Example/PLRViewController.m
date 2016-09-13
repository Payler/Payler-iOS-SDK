//
//  PLRViewController.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRViewController.h"
#import "PLRWebView.h"
#import "PLRSessionInfo.h"
#import "PLRPayment.h"
#import "PaylerAPIClient.h"

@interface PLRViewController ()<PLRWebViewDataSource>

@property (nonatomic, weak) IBOutlet PLRWebView *webView;
@property (nonatomic, weak) IBOutlet UIButton *chargeButton;
@property (nonatomic, weak) IBOutlet UIButton *refundButton;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PaylerAPIClient *client;

@end

@implementation PLRViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.sessionType == PLRSessionTypeOneStep) {
        self.title = @"Одностадийный платеж";
        self.chargeButton.hidden = YES;
    } else if (self.sessionType == PLRSessionTypeTwoStep) {
        self.title = @"Двухстадийный платеж";
        self.textLabel.text = @"Средства успешно заблокированы";
        [self.refundButton setTitle:@"Разблокировка" forState:UIControlStateNormal];
    }

    [self startPayment];
}

#pragma mark - PLRWebViewDataSource

- (PLRSessionInfo *)webViewSessionInfo:(PLRWebView *)sender {
    return self.sessionInfo;
}

- (PaylerAPIClient *)webViewClient:(PLRWebView *)sender {
    return self.client;
}

#pragma mark - Actions

- (IBAction)chargeButtonPressed:(UIButton *)sender {
    [self.client chargePayment:self.sessionInfo.paymentInfo completion:^(PLRPayment *payment, NSError *error) {
        if (!error) {
            self.textLabel.text = @"Средства успешно списаны";
            [self hideButtons];
        }
    }];
}

- (IBAction)refundButtonPressed:(UIButton *)sender {
    if (self.sessionType == PLRSessionTypeOneStep) {
        [self.client refundPayment:self.sessionInfo.paymentInfo completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                self.textLabel.text = @"Средства успешно возвращены";
                [self hideButtons];
            }
        }];
    } else if (self.sessionType == PLRSessionTypeTwoStep) {
        [self.client retrievePayment:self.sessionInfo.paymentInfo completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                self.textLabel.text = @"Средства успешно разблокированы";
                [self hideButtons];
            }
        }];
    }
}

#pragma mark - Private methods

- (void)startPayment {
    self.webView.dataSource = self;

#warning Здесь нужно указать ваши параметры.
    NSString *paymentId = [NSString stringWithFormat:@"SDK_iOS_%@", [[NSUUID UUID] UUIDString]];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:6000000 status:nil product:@"iPhone 6+" total:1 parameters:@{@"userData": @"test@test.com"}];
    NSURL *callbackURL = [NSURL URLWithString:[@"http://localhost:7820/Complete-order_id=" stringByAppendingString:paymentId]];
    self.sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:payment callbackURL:callbackURL sessionType:self.sessionType];
    self.client = [PaylerAPIClient testClientWithMerchantKey:@"" password:@""];

    [self.webView payWithCompletion:^(PLRPayment *payment, NSError *error) {
        if (!error) {
            if (self.sessionType == PLRSessionTypeTwoStep) {
                self.textLabel.text = @"Средства успешно заблокированы";
            }
            self.webView.hidden = YES;
        }
    }];
}

- (void)hideButtons {
    self.chargeButton.hidden = YES;
    self.refundButton.hidden = YES;
}

@end
