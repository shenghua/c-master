//
//  VAClassRoomViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 16/1/9.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAClassRoomViewController.h"
#import "VASessionRoomViewController.h"
#import "VASessionRoom1ViewController.h"
#import "VAMessages1ViewController.h"

#define kLoginApiHost @"http://mobapi.tutorabc.com/mobcommon/webapi/user/1/login"

@interface VAClassRoomViewController ()

@end

@implementation VAClassRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
//    VAMessages1ViewController *messageViewController = [[VAMessages1ViewController alloc] init];
//    [self presentViewController:messageViewController animated:YES completion:nil];
    
    [self showLiveSessionPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSDictionary *)genTestClassInfo {
    //    NSString *server = @"114.141.155.229";
    //    NSString *sessionSn = @"2015121010729";
    //    NSString *server = @"qa.tutormeet.com";
    //    NSString *sessionSn = @"2015120912994"; // relay
    //    NSString *sessionSn = @"2015120816993";
    //        NSString *server = @"fms1.vipabc.com";
    //        NSString *sessionSn = @"2014011716982";
    NSString *server = @"211.20.179.165";
    NSString *sessionSn = @"2014110317991";
    //    NSString *server = @"152.101.38.104";         // 152.101.38.104, Glass formal ip
    //    NSString *sessionSn = @"2015092312986";
    
    NSDictionary *classInfo = @{@"server":          server,
                                @"proxyServer":     @"61.64.50.146",
                                @"internalServer":  @"172.16.4.20",
                                @"vpn":             @"0",   // 1, 0
                                @"relay":           @"N",   // Y, N
                                
                                @"roomType":        @"1",   // 1: Normal, 2: Webcast1, 33: Tutor Glass
                                @"lobbySession":    @"N",   // Y, N
                                
                                @"ename":           @"Sendoh Chen",
                                @"clientSn":        @"932673",
                                @"role":            @"user",
                                @"sessionSn":       sessionSn,
                                @"firstName":       @"Sendoh",
                                @"compStatus":      @"abc",
                                @"sessionRoomId":   [NSString stringWithFormat:@"session%@", [sessionSn substringFromIndex:10]],
                                @"rating":          @"0.0",
                                @"cname":           @"陳勇宇",
                                @"closeType":       @"4"};
    return classInfo;
}

- (NSDictionary *)genTestClassInfo2
{
    
    NSDictionary *classInfo = @{@"server":   @"qa.tutormeet.com",
                                @"roomType":        @"1",
                                @"lobbySession":    @"N",   // Y, N
                                @"ename":           @"TingYao Hsu",
                                @"clientSn":        @"609897",
                                @"role":            @"user",
                                @"sessionSn":       @"2015120916994",
                                @"firstName":       @"TingYao",
                                @"compStatus":      @"abc",
                                @"sessionRoomId":   @"session994",
                                @"cname":           @"a",
                                @"rating":          @"0.0",
                                @"closeType":       @"4"
                                };
    
    return classInfo;
}

- (void)showLiveSessionPage
{
    [self retriveSessionRoomInfo:^(NSDictionary *classInfo) {
        
        if (!classInfo) classInfo = [self genTestClassInfo];
        
//        VASessionRoomViewController *vc = [[VASessionRoomViewController alloc] initWithClassInfo:classInfo isDemo:NO];
        
        VASessionRoom1ViewController *vc = [[VASessionRoom1ViewController alloc] initWithClassInfo:classInfo isDemo:NO];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }];

}

- (void)retriveSessionRoomInfo:(void (^)(NSDictionary *data))completionHandler {
    
//    if (!_emailTextField.text.length || !_pwdTextField.text.length) {
//        [SVProgressHUD showInfoWithStatus:@"QA mode"];
//        if (completionHandler) completionHandler(nil);
//        return;
//    }
    
    NSString *email = @"summerayxia@vipabc.com";
    NSString *password = @"xialei";
    [SVProgressHUD show];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kLoginApiHost];
    url.query = [@[[NSString stringWithFormat:@"deviceId=%@", @"386B2BA574FC4D0385F94ABC16185618"],
                   [NSString stringWithFormat:@"brandId=%@", @"2"],
                   [NSString stringWithFormat:@"account=%@", email],
                   [NSString stringWithFormat:@"password=%@", password]]
                 componentsJoinedByString:@"&"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"Login Fail QQ"];
            });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSLog(@"client login: %@", json);
//        [[Crashlytics sharedInstance] setObjectValue:json forKey:@"loginapi"];
        
        NSString *clientSn = [json[@"data"] isKindOfClass:NSDictionary.class]? json[@"data"][@"clientSn"]: @"";
        if (clientSn.length) {
//            [[Crashlytics sharedInstance] setUserIdentifier:clientSn];
            
            NSURL *enteressionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.tutorabc.com/aspx/reservationapi/reservationService/entersession?clientSn=%@", clientSn]];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:enteressionUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"enter session:%@", json);
//                [[Crashlytics sharedInstance] setObjectValue:json forKey:@"enter session"];
                
                id classInfo = json[@"result"][@"classInfo"];
                if (classInfo != [NSNull null]) {
                    NSString *classType = classInfo[@"classType"];
                    NSString *compStatus = classInfo[@"compStatus"];
                    NSString *sessionRoomId = classInfo[@"sessionRoomId"];
                    NSString *sessionRoomRandStr = classInfo[@"randStr"];
                    NSString *sessionSn = classInfo[@"sessionSn"];
                    NSString *userSn = clientSn;
                    
                    NSURLComponents *url = [[NSURLComponents alloc] initWithString:@"http://www.tutormeet.com/tutormeetweb/login.do"];
                    
                    url.query = [@[[NSString stringWithFormat:@"action=%@", @"tutormeetLogin"],
                                   [NSString stringWithFormat:@"class_type=%@", classType],
                                   [NSString stringWithFormat:@"comp_status=%@", compStatus],
                                   [NSString stringWithFormat:@"session_room_id=%@", sessionRoomId],
                                   [NSString stringWithFormat:@"session_room_rand_str=%@", sessionRoomRandStr],
                                   [NSString stringWithFormat:@"session_sn=%@", sessionSn],
                                   [NSString stringWithFormat:@"user_sn=%@", userSn]]
                                 componentsJoinedByString:@"&"];
                    
                    NSLog(@"login url: %@", url);
                    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSLog(@"error: %@", error.localizedDescription);
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                        NSLog(@"login.do: %@", json);
//                        [[Crashlytics sharedInstance] setObjectValue:json forKey:@"login.do"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showInfoWithStatus:@"Login succeed! :)"];
                            if (completionHandler) completionHandler(json);
                        });
                        
                    }];
                    [dataTask resume];
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:@"No classroom :("];
                        //                        if (completionHandler) completionHandler(nil);
                    });
                    NSLog(@"No class info");
                }
                
            }];
            [dataTask resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"Login Fail QQ"];
                //                if (completionHandler) completionHandler(nil);
            });
            NSLog(@"Login fail");
        }
    }];
    [dataTask resume];
    
}

@end
