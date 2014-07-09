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
}

- (instancetype)initWithFrame:(CGRect)frame client:(PaylerAPIClient *)client sessionInfo:(PLRSessionInfo *)sessionInfo {
    self = [self initWithFrame:frame];
    if (self) {
        _sessionInfo = sessionInfo;
        _client = client;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

- (void)payWithCompletion:(PLRPayBlock)completion {
    if (!self.sessionInfo) [NSException raise:@"RequiredParameter" format:@"'sessionInfo' is required."];
    if (!self.client) [NSException raise:@"RequiredParameter" format:@"'client' is required."];

    self.completionBlock = completion;

    [self.client startSessionWithInfo:self.sessionInfo completion:^(PLRPayment *payment, NSString *sessionId, NSDictionary *info, NSError *error) {
        if (!error) {
            NSString *path = [[NSURL URLWithString:@"Pay" relativeToURL:self.client.baseURL] absoluteString];
            NSDictionary *parameters = @{@"session_id": sessionId};
            NSMutableURLRequest *request = [self.client.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
            [self loadRequest:request];
        } else {
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] lastPathComponent] hasPrefix:@"Complete-order_id"]) {
        if (self.completionBlock) {
            self.completionBlock(YES, nil);
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.completionBlock) {
        self.completionBlock(NO, error);
    }
}

@end
