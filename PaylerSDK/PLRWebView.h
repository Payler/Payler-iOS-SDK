//
//  PLRWebView.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLRSessionInfo;

typedef void(^PLRCompletionBlock)(NSURLRequest *request, NSError *error);

@interface PLRWebView : UIWebView

@property (nonatomic, strong) PLRSessionInfo *sessionInfo;
@property (nonatomic, copy) NSString *merchantKey;

- (instancetype)initWithFrame:(CGRect)frame sessionInfo:(PLRSessionInfo *)sessionInfo merchantKey:(NSString *)merchantKey;

- (void)startSessionWithCompletion:(PLRCompletionBlock)completion;

@end
