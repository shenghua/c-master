//
//  VAWebViewController.h
//  VIPABC4Phone
//
//  Created by ledka on 15/12/29.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"

@interface VAWebViewController : VABaseViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSString *htmlPath;
@property (nonatomic, assign) BOOL needNavigateToEvaluatePage;
@property (nonatomic, copy) NSString *evaluatePage;

- (void)webViewLoadhtml:(NSString *)html;

@end
