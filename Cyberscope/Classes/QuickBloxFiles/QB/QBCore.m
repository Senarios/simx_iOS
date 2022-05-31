//
//  QBCore.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 03/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBCore.h"
#import "QBProfile.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

NSString *const QB_DEFAULT_PASSOWORD = @"12345678";

static NSString *loggedInStatus=@"logout";

@interface QBCore() <QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QBCoreDelegate> *multicastDelegate;
@property (strong, nonatomic) QBProfile *profile;


@property (assign, nonatomic) BOOL isAutorized;

@end

@implementation QBCore

+ (instancetype)instance {
    
    static QBCore *_core = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _core = [QBCore alloc];
        [_core commonInit];
    });
    
    return _core;
}

- (void)commonInit {
    
    _multicastDelegate = (id<QBCoreDelegate>)[[QBMulticastDelegate alloc] init];
    _profile = [QBProfile currentProfile];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [[QBChat instance] addDelegate:self];
    
}

- (void)clearProfile {
    [self.profile clearProfile];
}

- (void)addDelegate:(id <QBCoreDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QBCoreDelegate>)delegate{
    [self.multicastDelegate removeDelegate:delegate];
}
#pragma mark - QBChatDelegate

- (void)chatDidNotConnectWithError:(NSError *)error {
    
}

- (void)chatDidFailWithStreamError:(NSError *)error {
    
}

- (void)chatDidAccidentallyDisconnect {
}

- (void)chatDidReconnect {
    
}

#pragma mark - Current User

- (QBUUser *)currentUser {
    
    return self.profile.userData;
}
-(void)setCurrentUser:(QBUUser * _Nonnull)currentUser{
    [self.profile synchronizeWithUserData:currentUser];
}
- (void)setLoginStatus:(NSString *)loginStatus {
    
    if ([self.multicastDelegate respondsToSelector:@selector(core:loginStatus:)]) {
        [self.multicastDelegate core:self loginStatus:loginStatus];
    }
}

- (void)loginWithCurrentUser {
    
    dispatch_block_t connectToChat = ^{
        
        self.currentUser.password = QB_DEFAULT_PASSOWORD;
        QBUUser *user = self.currentUser;
        
        [self setLoginStatus:@"Login into chat ..."];
        
        [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
            
            if (error) {
                
                if (error.code == 401) {
                    
                    self.isAutorized = NO;
                    // Clean profile
                    [self.profile clearProfile];
                    // Notify about logout
                    if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogout:)]) {
                        loggedInStatus = @"logout";
                        [self.multicastDelegate coreDidLogout:self];
                    }
                }
                else {
                    [self handleError:error domain:ErrorDomainLogIn];
                    loggedInStatus = @"logout";
                }
            }
            else {
                
                if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogin:)]) {
                    loggedInStatus = @"loggedIn";
                    [self.multicastDelegate coreDidLogin:self];
                }
            }
        }];
    };
    
    if (self.isAutorized) {
        
        connectToChat();
        return;
    }
    
    [self setLoginStatus:loggedInStatus];
    NSLog(@"%@", self.currentUser.login);
    [QBRequest logInWithUserLogin:self.currentUser.login
                         password:QB_DEFAULT_PASSOWORD
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user)
     {
         self.isAutorized = YES;
         
         connectToChat();
         
         //[self registerForRemoteNotifications];
         
     } errorBlock:^(QBResponse * _Nonnull response) {
         loggedInStatus = @"logout";
         [self handleError:response.error.error domain:ErrorDomainLogIn];
         
         if (response.status == QBResponseStatusCodeUnAuthorized) {
             // Clean profile
             
             [self.profile clearProfile];
         }
     }];
}
- (NSString*) loggedInStatus{
    return loggedInStatus;
}
- (void)signUpWithFullName:(NSString *)fullName
                  roomName:(NSString *)roomName {
    
    NSParameterAssert(!self.currentUser);
    
    QBUUser *newUser = [QBUUser user];
    
    newUser.login = [NSUUID UUID].UUIDString;
    newUser.fullName = fullName;
    newUser.tags = @[roomName].mutableCopy;
    newUser.password = QB_DEFAULT_PASSOWORD;
    
    [self setLoginStatus:@"Signg up ..."];
    
    [QBRequest signUp:newUser
         successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user)
     {
         [self.profile synchronizeWithUserData:user];
         [self loginWithCurrentUser];
         
     } errorBlock:^(QBResponse * _Nonnull response) {
         
         [self handleError:response.error.error domain:ErrorDomainSignUp];
     }];
}

- (void)logout {
    
    dispatch_group_t logoutGroup = dispatch_group_create();
    
    dispatch_group_enter(logoutGroup);
    [self unsubscribeFromRemoteNotifications:^{
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_enter(logoutGroup);
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_notify(logoutGroup, dispatch_get_main_queue(), ^ {
        // Delete user from server
        [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
            
            loggedInStatus = @"logout";
            self.isAutorized = NO;
            // Clean profile
            [self.profile clearProfile];
            // Notify about logout
            if ([self.multicastDelegate respondsToSelector:@selector(coreDidLogout:)]) {
                [self.multicastDelegate coreDidLogout:self];
            }
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
            [self handleError:response.error.error domain:ErrorDomainLogOut];
        }];
    });
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType type = (UIUserNotificationTypeSound |
                                       UIUserNotificationTypeAlert |
                                       UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:type
                                          categories:nil];
        
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    }
}

- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSParameterAssert(deviceToken);
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void)unsubscribeFromRemoteNotifications:(dispatch_block_t)completionBlock {
    
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                                                  successBlock:^(QBResponse * _Nonnull response)
     {
         if (completionBlock) {
             completionBlock();
         }
         
     } errorBlock:^(QBError * _Nullable error) {
         
         if (completionBlock) {
             completionBlock();
         }
     }];
}

#pragma mark - Handle errors

- (void)handleError:(NSError *)error domain:(ErrorDomain)domain {
    
    if ([self.multicastDelegate respondsToSelector:@selector(core:error:domain:)]) {
        [self.multicastDelegate core:self error:error domain:domain];
    }
}


@end
