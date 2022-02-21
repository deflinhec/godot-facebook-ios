//
//  facebook.m
//  facebook
//
//  Created by Deflinhec on 2022/2/21.
//
#import <Foundation/Foundation.h>

#include "utils.h"
#include "facebook.h"

#include "core/class_db.h"

@import FBSDKCoreKit;
@import FBSDKShareKit;

Facebook *Facebook::instance = NULL;

Facebook::Facebook() {
	initialized = false;
	
	ERR_FAIL_COND(instance != NULL);
	
	instance = this;
	NSLog(@"initialize facebook");
}

Facebook::~Facebook() {
	if (instance == this) {
		instance = NULL;
	}
	NSLog(@"deinitialize facebook");
}

Facebook *Facebook::get_singleton() {
	return instance;
};

void Facebook::initialize(const String &appId)
{
	if (instance != this || initialized)
	{
		NSLog(@"Facebook Module already initialized");
		return;
	}
	NSLog(@"Facebook Module will try to initialize now");
	
	[[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
	loginManager = [[FBSDKLoginManager alloc] init];
	[[FBSDKSettings sharedSettings] setAppID:[NSString stringWithUTF8String:appId.utf8().get_data()]];
	emit_signal("initialization_complete");
}

static UIWindow* keyWindow()
{
	NSArray         *windows;
	UIWindow        *windowRoot = nil;
	if (@available(iOS 15, *)) {
		NSSet *scenes = [[UIApplication sharedApplication] connectedScenes];
		for (UIScene *scene in scenes) {
			if (scene.activationState == UISceneActivationStateForegroundActive) {
				if ([scene isKindOfClass:[UIWindowScene class]]) {
					windows = ((UIWindowScene*)scene).windows;
					break;
				}
			}
		}
	} else {
		windows = [[UIApplication sharedApplication] windows];
	}
	for (UIWindow   *window in windows) {
		if (window.isKeyWindow) {
			windowRoot = window;
			break;
		}
	}
	return windowRoot;
}

void Facebook::login(const Array permissions)
{
	if (![FBSDKAccessToken currentAccessToken]) {
		UIViewController *vc = [keyWindow() rootViewController];
		NSMutableArray *perms = [NSMutableArray new];
		for(int i=0; i<permissions.size(); i++) {
			Variant p = permissions[i];
			if(p.get_type() == Variant::STRING) {
				String sp = p;
				[perms addObject:[NSString stringWithUTF8String:sp.utf8().get_data()]];
			}
		}
		[loginManager logInWithPermissions:perms fromViewController:vc handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
						if (result.isCancelled) {
							emit_signal("login_canceled");
						} else if(error) {
							String errString(error.description.UTF8String);
							emit_signal("login_failed", errString);
						} else {
							String token(result.token.tokenString.UTF8String);
							emit_signal("login_success", token);
						}
					});
			}];
	} else {
		String token(FBSDKAccessToken.currentAccessToken.tokenString.UTF8String);
		emit_signal("login_success", token);
	}
}

void Facebook::logout()
{
	[loginManager logOut];
}

bool Facebook::is_logged_in()
{
	if ([FBSDKAccessToken currentAccessToken])
	{
		return true;
	}
	return false;
}

void Facebook::set_push_token(const String& token)
{
	NSData *data = [NSData dataWithBytes:token.utf8().get_data() length:token.utf8().length()];
	[[FBSDKAppEvents shared] setPushNotificationsDeviceToken:data];
}

void Facebook::log_event(const String& event)
{
	NSString *event_name = [NSString stringWithUTF8String:event.utf8().get_data()];
	[[FBSDKAppEvents shared] logEvent:event_name];
}

void Facebook::log_event_value(const String& event, double value)
{
	NSString *event_name = [NSString stringWithUTF8String:event.utf8().get_data()];
	[[FBSDKAppEvents shared] logEvent:event_name valueToSum:value];
}

void Facebook::log_event_params(const String& event, const Dictionary params)
{
	NSString *event_name = [NSString stringWithUTF8String:event.utf8().get_data()];
	NSDictionary *paramsDict = utils::convertFromDictionary(params);
	[[FBSDKAppEvents shared] logEvent:event_name parameters:paramsDict];
}

void Facebook::log_event_value_params(const String& event, double value, const Dictionary params)
{
	NSString *event_name = [NSString stringWithUTF8String:event.utf8().get_data()];
	NSDictionary *paramsDict = utils::convertFromDictionary(params);
	[[FBSDKAppEvents shared] logEvent:event_name valueToSum:value parameters:paramsDict];
}

void Facebook::set_advertiser_tracking(bool enabled)
{
	if (@available(iOS 14, *)) {
		[[FBSDKSettings sharedSettings] setAdvertiserTrackingEnabled: enabled];
	}
}

void Facebook::share_screen_shot(const String& image_path)
{
	NSString * imagePath = [NSString stringWithCString:image_path.utf8().get_data()
											  encoding:NSUTF8StringEncoding];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	SharingInterface::share_screen_shot(keyWindow(), image);
}

void Facebook::on_share_success()
{
	emit_signal("share_success");
}

void Facebook::on_share_failed(const String& error)
{
	emit_signal("share_failed", error);
}

void Facebook::on_share_cancelled()
{
	emit_signal("share_canceled");
}

void Facebook::_bind_methods()
{
    ADD_SIGNAL(MethodInfo("initialization_complete"));

	ADD_SIGNAL(MethodInfo("share_canceled"));
	ADD_SIGNAL(MethodInfo("share_success"));
	ADD_SIGNAL(MethodInfo("share_failed", PropertyInfo(Variant::STRING, "error")));
	
	ADD_SIGNAL(MethodInfo("login_canceled"));
	ADD_SIGNAL(MethodInfo("login_success", PropertyInfo(Variant::STRING, "token")));
	ADD_SIGNAL(MethodInfo("login_failed", PropertyInfo(Variant::STRING, "error")));
	
	ClassDB::bind_method(D_METHOD("initialize", "appId"), &Facebook::initialize);
	ClassDB::bind_method(D_METHOD("login", "permissions"), &Facebook::login);
	ClassDB::bind_method(D_METHOD("logout"), &Facebook::logout);
	ClassDB::bind_method(D_METHOD("is_logged_in"), &Facebook::is_logged_in);
	ClassDB::bind_method(D_METHOD("set_push_token", "token"), &Facebook::set_push_token);
	ClassDB::bind_method(D_METHOD("log_event"), &Facebook::log_event);
	ClassDB::bind_method(D_METHOD("log_event_value"), &Facebook::log_event_value);
	ClassDB::bind_method(D_METHOD("log_event_params"), &Facebook::log_event_params);
	ClassDB::bind_method(D_METHOD("log_event_value_params"), &Facebook::log_event_value_params);
	ClassDB::bind_method(D_METHOD("set_advertiser_tracking"), &Facebook::set_advertiser_tracking);
	ClassDB::bind_method(D_METHOD("share_screen_shot"), &Facebook::share_screen_shot);
}
