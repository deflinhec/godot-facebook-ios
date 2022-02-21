//
//  utils.m
//  facebook
//
//  Created by Deflinhec on 2022/2/22.
//

#include "utils.h"

namespace utils
{
	Variant convertToVariant(id val)
	{
		if([val isKindOfClass:NSDictionary.class]) {
			NSDictionary *nsd = (NSDictionary*)val;
			Dictionary dict;
			for(NSString *key in nsd.allKeys) {
				String k(key.UTF8String);
				dict[k] = convertToVariant(nsd[key]);
			}
			return Variant(dict);
		} else if([val isKindOfClass:NSArray.class]) {
			Array vec;
			for(id el in (NSArray*)val) {
				vec.push_back(convertToVariant(el));
			}
			return Variant(vec);
		} else if([val isKindOfClass:NSNumber.class]) {
			NSNumber *n = (NSNumber*)val;
			float f = n.floatValue;
			return Variant(f);
		} else if([val isKindOfClass:NSString.class]) {
			NSString *s = (NSString*)val;
			String str(s.UTF8String);
			return Variant(str);
		} else {
			// error
			NSString *err = [NSString stringWithFormat:@"Unknown conversion method for type: %@", [val description]];
			ERR_PRINT(err.UTF8String);
		}
		return Variant(false);
	}

	NSDictionary *convertFromDictionary(const Dictionary& dict)
	{
		NSMutableDictionary *result = [NSMutableDictionary new];
		for(int i=0; i<dict.size(); i++) {
			Variant key = dict.keys()[i];
			Variant val = dict.values()[i];
			if(key.get_type() == Variant::STRING) {
				String skey = key;
				NSString *strKey = [NSString stringWithUTF8String:skey.utf8().get_data()];
				if(val.get_type() == Variant::INT) {
					int i = (int)val;
					result[strKey] = @(i);
				} else if(val.get_type() == Variant::REAL) {
					double d = (double)val;
					result[strKey] = @(d);
				} else if(val.get_type() == Variant::STRING) {
					String sval = val;
					NSString *s = [NSString stringWithUTF8String:sval.utf8().get_data()];
					result[strKey] = s;
				} else if(val.get_type() == Variant::BOOL) {
					BOOL b = (bool)val;
					result[strKey] = @(b);
				} else {
					ERR_PRINT("Unexpected type as dictionary value");
				}
			} else {
				ERR_PRINT("Non string key in Dictionary");
			}
		}
		return result;
	}
}
