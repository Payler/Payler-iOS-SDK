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

static NSString *const APIBaseURL = @"https://sandbox.payler.com/gapi";

@interface PLRWebView ()<UIWebViewDelegate>

@end

@implementation PLRWebView

- (instancetype)initWithFrame:(CGRect)frame sessionInfo:(PLRSessionInfo *)sessionInfo merchantKey:(NSString *)merchantKey {
    self = [self initWithFrame:frame];
    if (self) {
        _sessionInfo = sessionInfo;
        _merchantKey = merchantKey;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

- (void)startSessionWithCompletion:(PLRCompletionBlock)completion {
    if (!self.sessionInfo) [NSException raise:@"RequiredParameter" format:@"'sessionInfo' is required."];
    if (!self.merchantKey) [NSException raise:@"RequiredParameter" format:@"'merchantKey' is required."];

    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

@end
