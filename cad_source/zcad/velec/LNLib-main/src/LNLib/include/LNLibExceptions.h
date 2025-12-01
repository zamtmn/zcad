/*
 * Author:
 * 2023/08/20 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include "Constants.h"
#include <stdexcept>
#include <string>

#define VALIDATE_ARGUMENT(condition,arg,message)\
	if(!(condition)){\
		throw std::invalid_argument((std::string(message)+"\r\nParameter name: "+#arg).c_str());\
	}

#define VALIDATE_ARGUMENT_RANGE(arg, min, max)\
	if(((arg)<(min) && std::fabs((arg)-(min))>Constants::DoubleEpsilon) || \
	  ((arg)>(max) && std::fabs((arg)-(max))>Constants::DoubleEpsilon)){\
		throw std::out_of_range("Argument is out of range["#min","#max"]\r\nParameter name: "#arg);\
	}




