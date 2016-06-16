//
//  RecordedWhiteboard.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import <Foundation/Foundation.h>
#import "LiveWhiteboard.h"
#import "SessionWhiteboardObject.h"

@interface RecordedWhiteboard : LiveWhiteboard
- (void)addObject:(SessionWhiteboardObject *)wbObject;
- (void)updateObject:(SessionWhiteboardObject *)wbObject;
@end
