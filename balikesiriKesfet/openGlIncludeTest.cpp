//
//  openGlIncludeTest.cpp
//  balikesiriKesfet
//
//  Created by xloop on 29/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#include "openGlIncludeTest.hpp"

glTesting::glTesting(int a){
    hiddenF = (float)a;
}

float glTesting::retFloat() {
    return hiddenF;
}
