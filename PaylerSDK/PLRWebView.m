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

@interface PLRWebView ()

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, copy) NSString *merchantKey;

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

- (instancetype)initWithFrame:(CGRect)frame sessionInfo:(PLRSessionInfo *)sessionInfo merchantKey:(NSString *)merchantKey {
    self = [self initWithFrame:frame];
    if (self) {
        if (!sessionInfo) [NSException raise:@"RequiredParameter" format:@"'sessionInfo' is required."];
        if (!merchantKey) [NSException raise:@"RequiredParameter" format:@"'merchantKey' is required."];

        _sessionInfo = sessionInfo;
        _merchantKey = merchantKey;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

#pragma mark - Private methods

- (void)commonInit {
    
}

@end
