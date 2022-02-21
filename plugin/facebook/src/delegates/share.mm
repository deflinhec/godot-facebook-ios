//
//  share.m
//  facebook
//
//  Created by Deflinhec on 2022/2/22.
//

#import <Foundation/Foundation.h>
#include "share.h"

SharingInterface::SharingInterface()
	: delegate([[SharingDelegate alloc] initWith:this])
{
}

SharingInterface::~SharingInterface()
{
	delegate = nullptr;
}

void SharingInterface::share_screen_shot(UIWindow* window, UIImage* image)
{
	FBSDKSharePhoto* photo = [[FBSDKSharePhoto alloc]init];
	photo.image = image;
	FBSDKSharePhotoContent* content = [[FBSDKSharePhotoContent alloc] init];
	content.photos = [[NSArray alloc]initWithObjects:photo, nil];
	[FBSDKShareDialog showFromViewController:[window rootViewController]
								 withContent:content delegate:delegate];
}

@implementation SharingDelegate

- (SharingDelegate*) initWith:(SharingInterface*)delegator
{
	instance = delegator; return self;
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary<NSString *, id> *)results
{
	if (instance == nullptr)
	{
		return;
	}
	instance->on_share_success();
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
	if (instance == nullptr)
	{
		return;
	}
	String errString(error.description.UTF8String);
	instance->on_share_failed(errString);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
	if (instance == nullptr)
	{
		return;
	}
	instance->on_share_cancelled();
}

@end
