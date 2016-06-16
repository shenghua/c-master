//
//  WbImage.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WbImage()
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, weak) WbImage *weakSelf;
@end

@implementation WbImage

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo {
    if (self = [super initWithWo:wo]) {
        _weakSelf = self;
        [self update:wo];
    }
    return self;
}

- (void)dealloc {
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
}

- (void)update:(SessionWhiteboardObject *)wo {
    __block NSString *imageUrl;
    [wo.properties enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        switch ([(NSNumber *)key intValue]) {
            case 0:
                _x = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 1:
                _y = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 2:
                _objId = [(NSNumber *)object intValue];
                break;
                
            case 3:
                _width = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 4:
                _height = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 5:
                imageUrl = [(NSString *)object copy];
                break;
                
            case 8:
                _isImage = [(NSNumber *)object boolValue];
                break;
                
            default:
                break;
        }
    }];
    
    if (imageUrl)
        [self _loadImageFromUrl:imageUrl];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        _weakSelf.frame = CGRectMake(_x, _y, _width, _height);
    });
}

- (void)_loadImageFromUrl:(NSString *)imageUrl {
    dispatch_async(dispatch_get_main_queue(), ^{
        
    if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(0, 0, _width, _height);
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:nil
                           options:SDWebImageRetryFailed|SDWebImageRefreshCached|SDWebImageContinueInBackground|SDWebImageHighPriority
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             
                             if (!error)
                                 [self addSubview:_imageView];
                         }];
    });
}

@end
