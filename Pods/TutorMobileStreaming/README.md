# TutorMobileStreaming

[![CI Status](http://img.shields.io/travis/TingYao Hsu/TutorMobileStreaming.svg?style=flat)](https://travis-ci.org/TingYao Hsu/TutorMobileStreaming) [![Version](https://img.shields.io/cocoapods/v/TutorMobileStreaming.svg?style=flat)](http://cocoapods.org/pods/TutorMobileStreaming) [![License](https://img.shields.io/cocoapods/l/TutorMobileStreaming.svg?style=flat)](http://cocoapods.org/pods/TutorMobileStreaming) [![Platform](https://img.shields.io/cocoapods/p/TutorMobileStreaming.svg?style=flat)](http://cocoapods.org/pods/TutorMobileStreaming)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Cocoapods 

Xcode 6.x or later



## Installation

TutorMobileStreaming is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

``` ruby
pod "TutorMobileStreaming", git:'http://gitlab.tutorabc.com/TutorMeet/TutorMobile-iOS-Streaming.git'
```

## Author

Sendoh Chen, sendohchen@tutorabc.com

TingYao Hsu, tingyaohsu@tutorabc.com



# TutorMobileSDK-iOS-Streaming

This is a Demo project for Session Room streaming media framework.

All you need to do is to pass **class info** to *UIViewController+SessionRoom* Category methods.



## Sample Code - 進教室

### Live Session Room Type1 in UIViewController

![](doc/screenshot-livesessiontype1.png)

``` objective-c
#import <TutorMobileStreaming/TutorMobileStreaming.h>

- (void)viewDidLoad {
  NSDictionary *classInfo = @{
                @"classType": @"37",
                @"compStatus": @"abc",
                @"sessionRoomId": @"session1001",
                @"randStr": @"0B49D7DA49",
                @"sessionSn": @"20140224011001",
                @"clientSn": @"90357",
  				@"isDemo":@YES};
  [self showLiveSessionType1WithClassInfo:classInfo];
  [self showRecordSessionType1WithClassInfo:classInfo
                                 completion:^(NSError *err){
      if (err) {
  		// Error Handling
      }
  }];
}
```





### Live Session Room Type2 (Instant Class UI)

![](doc/screenshot-livesessiontype2.png)



``` objective-c
#import <TutorMobileStreaming/TutorMobileStreaming.h>

- (void)viewDidLoad {

  NSDictionary *classInfo = @{
    @"ClassType": @"37",
    @"ClientSn": @"735623",
    @"CompStatus": @"abc",
    @"SessionRoomId": @"instsvc000831",
    @"RoomRandString": @"0B49D7DA49",
    @"SessionSn": @"201511120000341",
  };
  [self showLiveSessionType2WithClassInfo:classInfo
							   completion:^(NSError *err){
      if (err) {
  		// Error Handling
      }
  }];
}
```



## Sample Code - 錄影檔

### Record Session Room Type1 in UIViewController with Record.do API

透過 Record.do API 取得錄影檔資訊.

``` objective-c
#import <TutorMobileStreaming/TutorMobileStreaming.h>

- (void)viewDidLoad {
    NSDictionary *classInfo = @{@"fileName": @"_recording_session001286_654rqKOjPr_2015112013001286",
                                @"compStatus": @"abc",
                                @"clientSn": @"111111",
                                @"classStartMin": @"10"};
    [self showRecordSessionType1WithClassInfo:classInfo completion:^(NSError *err){
  		if (err) {
  			// Error Handling
		}
	}];
}
```



### Recorded Session Room Type1 in UIViewController without Record.do API

顯示免費錄影檔.

``` objective-c
#import <TutorMobileStreaming/TutorMobileStreaming.h>

- (void)viewDidLoad {
    NSDictionary *classInfo = @{@"serverIP": @"210.5.31.86",
                                @"videoName": @"_recording_session001286_654rqKOjPr_2015112013001286",
                                @"classStartMin": @"10"};
    [self showFreeSessionType1WithClassInfo:classInfo completion:^(NSError *err){
  		if (err) {
  			// Error Handling
		}
	}];
}
```