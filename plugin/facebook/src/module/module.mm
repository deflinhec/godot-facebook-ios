//
//  module.mm
//  module
//
//  Created by Deflinhec on 22/02/22.
//

#import "module.h"

Facebook * facebook;

void register_facebook_types() {
    NSLog(@"init facebook plugin");

    facebook = memnew(Facebook);
    Engine::get_singleton()->add_singleton(Engine::Singleton("Facebook", facebook));
}

void unregister_facebook_types() {
    NSLog(@"deinit facebook plugin");
    
    if (facebook) {
       memdelete(facebook);
	}
}
