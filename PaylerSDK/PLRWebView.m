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
#import <AFNetworking/AFHTTPSessionManager.h>
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

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<PLRWebViewDataSource>)dataSource {
    self = [self initWithFrame:frame];
    if (self) {
        self.dataSource = dataSource;
    }
    return self;
}

- (void)commonInit {
    self.delegate = self;
    self.scalesPageToFit = YES;

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityView];
    self.activityView = activityView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activityView.center = CGPointMake(CGRectGetWidth(self.frame)/2, 40.0);
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

- (void)setDataSource:(id<PLRWebViewDataSource>)dataSource {
    if (![dataSource conformsToProtocol:@protocol(PLRWebViewDataSource)]) {
        [NSException raise:NSInvalidArgumentException format:@"dataSource doesn't conform to protocol."];
    }

    _dataSource = dataSource;
}

- (void)payWithCompletion:(PLRPayBlock)completion {
    PLRSessionInfo *sessionInfo = [self.dataSource webViewSessionInfo:self];
    PaylerAPIClient *client = [self.dataSource webViewClient:self];
    if (!sessionInfo) [NSException raise:NSInvalidArgumentException format:@"'sessionInfo' is required."];
    if (!client) [NSException raise:NSInvalidArgumentException format:@"'client' is required."];

    self.completionBlock = completion;

    [self.activityView startAnimating];
    [client startSessionWithInfo:sessionInfo completion:^(PLRPayment *payment, NSString *sessionId, NSError *error) {
        if (!error) {
            NSString *path = [[NSURL URLWithString:@"Pay" relativeToURL:client.baseURL] absoluteString];
            NSDictionary *parameters = @{@"session_id": sessionId};
            NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
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
    PLRSessionInfo *sessionInfo = [self.dataSource webViewSessionInfo:self];
    PaylerAPIClient *client = [self.dataSource webViewClient:self];
    if ([[[request URL] absoluteString] isEqualToString:[sessionInfo.callbackURL absoluteString]]) {

        if (!self.activityView.isAnimating) [self.activityView startAnimating];
        [client fetchStatusForPaymentWithId:sessionInfo.paymentInfo.paymentId completion:^(PLRPayment *payment, NSError *error) {
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
