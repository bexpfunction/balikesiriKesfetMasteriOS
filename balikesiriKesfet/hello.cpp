//
//  hello.cpp
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#include "hello.hpp"
Greeting::Greeting() {
    greeting = "Hello C++!";
}

std::string Greeting::greet() {
    return greeting;
}
