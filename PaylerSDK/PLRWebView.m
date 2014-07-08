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

@property (nonatomic, copy) PLRCompletionBlock completionBlock;

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

- (void)startSessionWithCompletion:(PLRCompletionBlock)completion {
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
            completion(operation.responseObject, error);
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
}

@end
