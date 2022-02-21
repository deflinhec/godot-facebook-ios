//
//  utils.h
//  facebook
//
//  Created by Deflinhec on 2022/2/22.
//
#pragma once

#import <Foundation/Foundation.h>

#include "core/object.h"

namespace utils
{
	Variant convertToVariant(id val);

	NSDictionary *convertFromDictionary(const Dictionary& dict);
}
