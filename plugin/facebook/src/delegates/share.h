//
//  share.h
//  facebook
//
//  Created by Deflinhec on 2022/2/22.
//

#pragma once

#include "core/object.h"

@import FBSDKShareKit;

class SharingInterface;

@interface SharingDelegate : NSObject <FBSDKSharingDelegate>
{
	SharingInterface* instance;
}

- (SharingDelegate*)initWith:(SharingInterface*)delegator;

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary<NSString *, id> *)results;

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error;

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer;

@end

class SharingInterface
{
#ifdef __OBJC__
	SharingDelegate* delegate;
#else
	void* delegate;
#endif
	
public:
	
	void share_screen_shot(UIWindow* window, UIImage* image);

	virtual void on_share_success() = 0;
	
	virtual void on_share_failed(const String& error) = 0;
	
	virtual void on_share_cancelled() = 0;
	
public:
	
	SharingInterface();
	virtual ~SharingInterface();
};
