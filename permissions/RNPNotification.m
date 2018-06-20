//
//  RNPNotification.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPNotification.h"

static NSString* RNPDidAskForNotification = @"RNPDidAskForNotification";

@interface RNPNotification()
@property (copy) void (^completionHandler)(NSString*);
@end

@implementation RNPNotification

+ (NSString *)getStatus
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:RNPDidAskForNotification];
    
    if (didAskForPermission) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS8+
            BOOL isRegistered = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
            BOOL isEnabled = [[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone;
            if (isRegistered || isEnabled) {
                return isEnabled ? RNPStatusAuthorized : RNPStatusDenied;
            }
            else {
                return RNPStatusDenied;
            }
        } else {
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return RNPStatusDenied;
            }
            else {
                return RNPStatusAuthorized;
            }
        }
    } else {
        return RNPStatusUndetermined;
    }
}

- (void)request:(UIUserNotificationType)types completionHandler:(void (^)(NSString*))completionHandler
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:RNPDidAskForNotification];
    if (!didAskForPermission) {
        self.completionHandler = completionHandler;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS8+
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)types];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RNPDidAskForNotification];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        completionHandler([self.class getStatus]);
    }
}

- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    if (self.completionHandler) {
        //for some reason, checking permission right away returns denied. need to wait a tiny bit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.completionHandler([self.class getStatus]);
            self.completionHandler = nil;
        });
    }
}

@end
