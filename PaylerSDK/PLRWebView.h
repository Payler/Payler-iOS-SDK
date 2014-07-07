//
//  PLRWebView.h
//  PaylerSDK
//
//  Created by Максим Павлов on 07.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLRSessionInfo;

@interface PLRWebView : UIWebView

- (instancetype)initWithFrame:(CGRect)frame sessionInfo:(PLRSessionInfo *)sessionInfo merchantKey:(NSString *)merchantKey;

@end
