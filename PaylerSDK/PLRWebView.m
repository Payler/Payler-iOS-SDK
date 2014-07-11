//
//  PLRWebView.m
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRWebView.h"
#import "PLRSessionInfo.h"
#import "PLRPayment.h"
#import <AFHTTPRequestOperationManager.h>
#import "PaylerAPIClient.h"

@interface PLRWebView ()<UIWebViewDelegate>

@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) PLRPayBlock completionBlock;

@end

@implementation PLRWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self commonInit];
}

- (void)commonInit {
    self.delegate = self;
    self.scalesPageToFit = YES;

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(CGRectGetWidth(self.frame)/2, 40.0);
    [self addSubview:activityView];
    self.activityView = activityView;
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

- (void)payWithCompletion:(PLRPayBlock)completion {
    if (!self.sessionInfo) [NSException raise:@"RequiredParameter" format:@"'sessionInfo' is required."];
    if (!self.client) [NSException raise:@"RequiredParameter" format:@"'client' is required."];

    self.completionBlock = completion;

    [self.activityView startAnimating];
    [self.client startSessionWithInfo:self.sessionInfo completion:^(PLRPayment *payment, NSString *sessionId, NSDictionary *info, NSError *error) {
        if (!error) {
            NSString *path = [[NSURL URLWithString:@"Pay" relativeToURL:self.client.baseURL] absoluteString];
            NSDictionary *parameters = @{@"session_id": sessionId};
            NSMutableURLRequest *request = [self.client.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
            [self loadRequest:request];
        } else {
            [self.activityView stopAnimating];
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] absoluteString] isEqualToString:[self.sessionInfo.callbackURL absoluteString]]) {

        if (!self.activityView.isAnimating) [self.activityView startAnimating];
        [self.client fetchStatusForPaymentWithId:self.sessionInfo.paymentInfo.paymentId completion:^(PLRPayment *payment, NSDictionary *info, NSError *error) {
            [self.activityView stopAnimating];
            if (self.completionBlock) {
                self.completionBlock(payment, error);
            }
        }];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!self.activityView.isAnimating) [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityView stopAnimating];
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
}

@end
