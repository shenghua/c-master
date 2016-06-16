//
//  UIViewController+AlertView.m
//  Pods
//
//  Created by TingYao Hsu on 2015/9/10.
//
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)
+ (AlertView *)showAlertWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text {
    return [[AlertView alloc] initWithImage:image title:title text:text];
}
@end
