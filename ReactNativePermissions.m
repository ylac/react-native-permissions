//
//  ReactNativePermissions.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

@import Contacts;

#import "ReactNativePermissions.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

#import "RNPLocation.h"
#import "RNPBluetooth.h"
#import "RNPNotification.h"
#import "RNPAudioVideo.h"
#import "RNPEvent.h"
#import "RNPPhoto.h"
#import "RNPContacts.h"
#import "RNPBackgroundRefresh.h"

@interface ReactNativePermissions()
@property (strong, nonatomic) RNPLocation *locationMgr;
@property (strong, nonatomic) RNPNotification *notificationMgr;
@property (strong, nonatomic) RNPBluetooth *bluetoothMgr;
@end

@implementation ReactNativePermissions


RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
    }
    
    return self;
}

/**
 * run on the main queue.
 */
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(UIApplicationOpenSettingsURLString != nil));
}

RCT_EXPORT_METHOD(openSettings)
{
    if (@(UIApplicationOpenSettingsURLString != nil)) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

RCT_REMAP_METHOD(getPermissionStatus, getPermissionStatus:(RNPType)type resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;
    
    switch (type) {
            
        case RNPTypeLocation:
            status = [RNPLocation getStatus];
            break;
        case RNPTypeCamera:
            status = [RNPAudioVideo getStatus:@"video"];
            break;
        case RNPTypeMicrophone:
            status = [RNPAudioVideo getStatus:@"audio"];
            break;
        case RNPTypePhoto:
            status = [RNPPhoto getStatus];
            break;
        case RNPTypeContacts:
            status = [RNPContacts getStatus];
            break;
        case RNPTypeEvent:
            status = [RNPEvent getStatus:@"event"];
            break;
        case RNPTypeReminder:
            status = [RNPEvent getStatus:@"reminder"];
            break;
        case RNPTypeBluetooth:
            status = [RNPBluetooth getStatus];
            break;
        case RNPTypeNotification:
            status = [RNPNotification getStatus];
            break;
        case RNPTypeBackgroundRefresh:
            status = [RNPBackgroundRefresh getStatus];
            break;
        default:
            break;
    }

    resolve(status);
}

RCT_REMAP_METHOD(requestPermission, permissionType:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;
    
    switch (type) {
        case RNPTypeLocation:
            return [self requestLocation:json resolve:resolve];
        case RNPTypeCamera:
            return [RNPAudioVideo request:@"video" completionHandler:resolve];
        case RNPTypeMicrophone:
            return [RNPAudioVideo request:@"audio" completionHandler:resolve];
        case RNPTypePhoto:
            return [RNPPhoto request:resolve];
        case RNPTypeContacts:
            return [RNPContacts request:resolve];
        case RNPTypeEvent:
            return [RNPEvent request:@"event" completionHandler:resolve];
        case RNPTypeReminder:
            return [RNPEvent request:@"reminder" completionHandler:resolve];
        case RNPTypeBluetooth:
            return [self requestBluetooth:resolve];
        case RNPTypeNotification:
            return [self requestNotification:json resolve:resolve];
        default:
            break;
    }
    

}


- (void) requestLocation:(id)json resolve:(RCTPromiseResolveBlock)resolve
{
    if (self.locationMgr == nil) {
        self.locationMgr = [[RNPLocation alloc] init];
    }
    
    NSString *type = [RCTConvert NSString:json];
    
    [self.locationMgr request:type completionHandler:resolve];
}

- (void) requestNotification:(id)json resolve:(RCTPromiseResolveBlock)resolve
{
    NSArray *typeStrings = [RCTConvert NSArray:json];
    
    UIUserNotificationType types;
    if ([typeStrings containsObject:@"alert"])
        types = types | UIUserNotificationTypeAlert;
    
    if ([typeStrings containsObject:@"badge"])
        types = types | UIUserNotificationTypeBadge;
    
    if ([typeStrings containsObject:@"sound"])
        types = types | UIUserNotificationTypeSound;
    
    
    if (self.notificationMgr == nil) {
        self.notificationMgr = [[RNPNotification alloc] init];
    }
    
    [self.notificationMgr request:types completionHandler:resolve];

}


- (void) requestBluetooth:(RCTPromiseResolveBlock)resolve
{
    if (self.bluetoothMgr == nil) {
        self.bluetoothMgr = [[RNPBluetooth alloc] init];
    }
    
    [self.bluetoothMgr request:resolve];
}




@end
