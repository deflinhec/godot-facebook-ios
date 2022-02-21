//
//  facebook.h
//  facebook
//
//  Created by Deflinhec on 2022/2/21.
//
#pragma once

#include "core/object.h"
#include "delegates/share.h"

@import FBSDKLoginKit;

class Facebook : public Object, public SharingInterface {
	GDCLASS(Facebook, Object);
	
	bool initialized;
	static Facebook *instance;
	
#ifdef __OBJC__
	FBSDKLoginManager* loginManager;
#else
	void* loginManager;
#endif

protected:
	static void _bind_methods();
	
public:
	void initialize(const String& appId);
	
	void login(const Array permissions);
	
	void logout();
	
	bool is_logged_in();
	
	void set_push_token(const String& token);
	
	void log_event(const String& event);
	
	void log_event_value(const String& event, double value);
	
	void log_event_params(const String& event, const Dictionary params);
	
	void log_event_value_params(const String& event, double value, const Dictionary params);
	
	void set_advertiser_tracking(bool enabled);
	
	void share_screen_shot(const String& image_path);
	
	virtual void on_share_success();
	
	virtual void on_share_failed(const String& error);
	
	virtual void on_share_cancelled();

	Facebook();
	~Facebook();

	static Facebook *get_singleton();
private:

};
