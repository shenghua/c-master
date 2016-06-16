//
//  WbObjectFactory.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbObjectFactory.h"
#import "WbLine.h"
#import "WbRectangle.h"
#import "WbCircle.h"
#import "WbTriangle.h"
#import "WbFreehand.h"
#import "WbText.h"
#import "WbImage.h"

@implementation WbObjectFactory

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject_LineRectangleCircle:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    for (int i = 0; i < wo->propertyNum; i++) {
        if (wo->propertyId[i] == 0 || wo->propertyId[i] == 1 || wo->propertyId[i] == 2 ||  wo->propertyId[i] == 3 || wo->propertyId[i] == 4 || wo->propertyId[i] == 5 ||
            wo->propertyId[i] == 6 || wo->propertyId[i] == 7) {
            
            sessionWb.properties[@(wo->propertyId[i])] = @((int)AMFProp_GetNumber(&wo->properties[i]));
        }
    }
    
    return sessionWb;
}

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject_Triangle:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    for (int i = 0; i < wo->propertyNum; i++) {
        if (wo->propertyId[i] == 0 || wo->propertyId[i] == 1 || wo->propertyId[i] == 2 ||  wo->propertyId[i] == 3 || wo->propertyId[i] == 4 || wo->propertyId[i] == 5 ||
            wo->propertyId[i] == 6 || wo->propertyId[i] == 7 || wo->propertyId[i] == 8) {
            
            sessionWb.properties[@(wo->propertyId[i])] = @((int)AMFProp_GetNumber(&wo->properties[i]));
        }
    }
    
    return sessionWb;
}

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject_FreehandMarker:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    for (int i = 0; i < wo->propertyNum; i++) {
        if (wo->propertyId[i] == 0 || wo->propertyId[i] == 1 || wo->propertyId[i] == 2 ||  wo->propertyId[i] == 3 || wo->propertyId[i] == 4) {
            sessionWb.properties[@(wo->propertyId[i])] = @((int)AMFProp_GetNumber(&wo->properties[i]));
        }
        else if (wo->propertyId[i] == 5) {
            sessionWb.properties[@(5)] = [NSMutableArray new];
            
            AMFObject propertiesObj;
            AMFProp_GetObject(&wo->properties[5], &propertiesObj);
            
            for (int j = 0; j < propertiesObj.o_num; j++) {
                AMFObjectProperty *property = AMF_GetProp(&propertiesObj, NULL, j);
                
                if (AMFProp_IsValid(property)) {
                    AMFObject propertyObj;
                    AMFProp_GetObject(property, &propertyObj);
                    
                    if (propertyObj.o_num > 0) {
                        int x = (int)AMFProp_GetNumber(AMF_GetProp(&propertyObj, NULL, 0));
                        int y = (int)AMFProp_GetNumber(AMF_GetProp(&propertyObj, NULL, 1));
                        
                        [sessionWb.properties[@(5)] addObject:@[@(x), @(y)]];
                    }
                }
            }
        }
    }
    
    return sessionWb;
}

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject_Text:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    for (int i = 0; i < wo->propertyNum; i++) {
        if (wo->propertyId[i] == 0 || wo->propertyId[i] == 1 || wo->propertyId[i] == 2 ||  wo->propertyId[i] == 3 || wo->propertyId[i] == 4 || wo->propertyId[i] == 5 ||
            wo->propertyId[i] == 8 || wo->propertyId[i] == 9 || wo->propertyId[i] == 10 || wo->propertyId[i] == 11) {
            
            sessionWb.properties[@(wo->propertyId[i])] = @((int)AMFProp_GetNumber(&wo->properties[i]));
        }
        else if (wo->propertyId[i] == 6 || wo->propertyId[i] == 7) {
            @autoreleasepool {
                AVal text;
                AMFProp_GetString(&wo->properties[i], &text);
                char *textStr = malloc(text.av_len + 1);
                memcpy(textStr, text.av_val, text.av_len);
                textStr[text.av_len] = '\0';
                sessionWb.properties[@(wo->propertyId[i])] = [[NSString stringWithCString:textStr encoding:NSUTF8StringEncoding] copy];
                free(textStr);
            }
        }
    }
    
    return sessionWb;
}

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject_Image:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    for (int i = 0; i < wo->propertyNum; i++) {
        if (wo->propertyId[i] == 0 || wo->propertyId[i] == 1 || wo->propertyId[i] == 2 ||  wo->propertyId[i] == 3 || wo->propertyId[i] == 4 ||
            wo->propertyId[i] == 8) {
            
            sessionWb.properties[@(wo->propertyId[i])] = @((int)AMFProp_GetNumber(&wo->properties[i]));
        }
        else if (wo->propertyId[i] == 5) {
            @autoreleasepool {
                AVal url;
                AMFProp_GetString(&wo->properties[5], &url);
                char *urlStr = malloc(url.av_len + 1);
                memcpy(urlStr, url.av_val, url.av_len);
                urlStr[url.av_len] = '\0';
                sessionWb.properties[@(5)] = [[NSString stringWithCString:urlStr encoding:NSUTF8StringEncoding] copy];
                free(urlStr);
            }
        }
    }
    
    return sessionWb;
}

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [SessionWhiteboardObject new];
    sessionWb.shape = wo->shape;
    
    switch (wo->shape) {
        case WhiteboardShape_Line:
        case WhiteboardShape_Rectangle:
        case WhiteboardShape_Circle:
            return [self getRecordedWbObjectFromLiveWbObject_LineRectangleCircle:wo];
            
        case WhiteboardShape_Triangle:
            return [self getRecordedWbObjectFromLiveWbObject_Triangle:wo];
            
        case WhiteboardShape_Freehand:
        case WhiteboardShape_Marker:
            return [self getRecordedWbObjectFromLiveWbObject_FreehandMarker:wo];
            
        case WhiteboardShape_Text:
            return [self getRecordedWbObjectFromLiveWbObject_Text:wo];
            
        case WhiteboardShape_Image:
            return [self getRecordedWbObjectFromLiveWbObject_Image:wo];
            
        default:
            sessionWb = nil;
    }

    return sessionWb;
}

+ (WbObject *)createLiveWbObject:(WhiteboardObject *)wo {
    SessionWhiteboardObject *sessionWb = [self getRecordedWbObjectFromLiveWbObject:wo];
    
    return [self createRecordedWbObject:sessionWb];
}

+ (WbObject *)createRecordedWbObject:(SessionWhiteboardObject *)wo {
    if (!wo)
        return nil;
    
    switch (wo.shape) {
        case WhiteboardShape_Line:
            return [[WbLine alloc] initWithWo:wo];
            
        case WhiteboardShape_Rectangle:
            return [[WbRectangle alloc] initWithWo:wo];
            
        case WhiteboardShape_Circle:
            return [[WbCircle alloc] initWithWo:wo];
            
        case WhiteboardShape_Triangle:
            return [[WbTriangle alloc] initWithWo:wo];
            
        case WhiteboardShape_Freehand:
            return [[WbFreehand alloc] initWithWo:wo];
            
        case WhiteboardShape_Text:
            return [[WbText alloc] initWithWo:wo];
            
        case WhiteboardShape_Image:
            return [[WbImage alloc] initWithWo:wo];
            
        case WhiteboardShape_Marker:
        {
            WbFreehand *wbFreehand = [[WbFreehand alloc] initWithWo:wo];
            wbFreehand.alpha = 0.5;
            return wbFreehand;
        }
        default:
            return nil;
    }
}
@end
