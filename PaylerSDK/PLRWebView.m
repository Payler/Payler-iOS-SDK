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

static NSString *const APIBaseURL = @"https://sandbox.payler.com/gapi";

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

- (void)startSessionWithCompletion:(PLRPayBlock)completion {
    if (!self.sessionInfo) [NSException raise:@"RequiredParameter" format:@"'sessionInfo' is required."];
    if (!self.merchantKey) [NSException raise:@"RequiredParameter" format:@"'merchantKey' is required."];

    self.completionBlock = completion;

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURL]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    [parameters addEntriesFromDictionary:[self.sessionInfo dictionaryRepresentation]];

    [manager POST:@"StartSession" parameters:[parameters copy] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"#network <%@: %@> \nResponse: %@", operation.request.HTTPMethod, [operation.request.URL absoluteString], responseObject);
        NSString *sessionId = responseObject[@"session_id"];
        if (sessionId.length) {
            NSString *path = [[NSURL URLWithString:@"Pay" relativeToURL:manager.baseURL] absoluteString];
            NSDictionary *parameters = @{@"session_id": sessionId};
            NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
            [self loadRequest:request];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(operation.request, error);
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request: %@", request);
    if ([[[request URL] lastPathComponent] hasPrefix:@"Complete-order_id"]) {
        if (self.completionBlock) {
            self.completionBlock(request, nil);
            self.completionBlock = nil;
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
    NSLog(@"Error: %@", error);
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
}

@end
