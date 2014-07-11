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

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, strong) PaylerAPIClient *client;

@end

@implementation PLRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *paymentId = [NSString stringWithFormat:@"SDK_iOS_%@", [[NSUUID UUID] UUIDString]];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:100];
    NSURL *callbackURL = [NSURL URLWithString:[@"http://localhost:7820/Complete-order_id=" stringByAppendingString:paymentId]];
    self.sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:payment callbackURL:callbackURL];
    self.client = [[PaylerAPIClient alloc] initWithMerchantKey:nil password:nil];

    self.webView.dataSource = self;
    [self.webView payWithCompletion:^(PLRPayment *payment, NSError *error) {
        if (!error) {
            self.webView.hidden = YES;
        }
    }];
}

#pragma mark - PLRWebViewDataSource

- (PLRSessionInfo *)webViewSessionInfo:(PLRWebView *)sender {
    return self.sessionInfo;
}

- (PaylerAPIClient *)webViewClient:(PLRWebView *)sender {
    return self.client;
}

@end
