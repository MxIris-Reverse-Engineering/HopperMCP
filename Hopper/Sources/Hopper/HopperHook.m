//
//  HopperHook.m
//  Hopper
//
//  Created by JH on 2025/4/8.
//

#import "HopperHook.h"
#import <objc/runtime.h>
#import "HPSwiftFieldDesc.h"
#import "HPSwiftTypeDesc.h"
#import "HPSwiftProtocolDesc.h"

#import "Hopper.h"

@implementation HopperHook

+ (void)load {
    Class SwiftFieldDescClass = NSClassFromString(@"SwiftFieldDesc");
    if (SwiftFieldDescClass && !class_conformsToProtocol(SwiftFieldDescClass, @protocol(HPSwiftFieldDesc))) {
        class_addProtocol(SwiftFieldDescClass, @protocol(HPSwiftFieldDesc));
    }
    
    Class SwiftTypeDescClass = NSClassFromString(@"SwiftTypeDesc");
    if (SwiftTypeDescClass && !class_conformsToProtocol(SwiftTypeDescClass, @protocol(HPSwiftTypeDesc))) {
        class_addProtocol(SwiftTypeDescClass, @protocol(HPSwiftTypeDesc));
    }
    
    Class SwiftProtocolDescClass = NSClassFromString(@"SwiftProtocolDesc");
    if (SwiftProtocolDescClass && !class_conformsToProtocol(SwiftProtocolDescClass, @protocol(HPSwiftProtocolDesc))) {
        class_addProtocol(SwiftProtocolDescClass, @protocol(HPSwiftProtocolDesc));
    }
    
    Class SwiftTypeSpecificDescClass = NSClassFromString(@"SwiftTypeSpecificDesc");
    if (SwiftTypeSpecificDescClass && !class_conformsToProtocol(SwiftTypeSpecificDescClass, @protocol(HPSwiftTypeSpecificDesc))) {
        class_addProtocol(SwiftTypeSpecificDescClass, @protocol(HPSwiftTypeSpecificDesc));
    }
    
    Class SwiftEnumDescClass = NSClassFromString(@"SwiftEnumDesc");
    if (SwiftEnumDescClass && !class_conformsToProtocol(SwiftEnumDescClass, @protocol(HPSwiftEnumDesc))) {
        class_addProtocol(SwiftEnumDescClass, @protocol(HPSwiftEnumDesc));
    }
    
    Class SwiftStructDescClass = NSClassFromString(@"SwiftStructDesc");
    if (SwiftStructDescClass && !class_conformsToProtocol(SwiftStructDescClass, @protocol(HPSwiftStructDesc))) {
        class_addProtocol(SwiftStructDescClass, @protocol(HPSwiftStructDesc));
    }
    
    Class SwiftClassDescClass = NSClassFromString(@"SwiftClassDesc");
    if (SwiftClassDescClass && !class_conformsToProtocol(SwiftClassDescClass, @protocol(HPSwiftClassDesc))) {
        class_addProtocol(SwiftClassDescClass, @protocol(HPSwiftClassDesc));
    }
}

@end
