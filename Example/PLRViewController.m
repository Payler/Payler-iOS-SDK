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

@interface PLRViewController ()

@property (nonatomic, weak) IBOutlet PLRWebView *webView;

@end

@implementation PLRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *paymentId = [NSString stringWithFormat:@"SDK_iOS_%@", [[NSDate date] description]];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:100];
    self.webView.sessionInfo = [[PLRSessionInfo alloc] initWithPaymentInfo:payment
                                                               callbackURL:[NSURL URLWithString:@"http://do-terema.ru/paylerbronok.php"]];
    self.webView.client = [[PaylerAPIClient alloc] init];
    [self.webView payWithCompletion:^(BOOL success, NSError *error) {
        if (!error) {
            NSLog(@"%@", @(success));
        }
    }];
}

@end
