//
//  SampleTool.m
//  SampleTool
//
//  Created by Vincent Bénony on 06/03/2014.
//  Copyright (c) 2014 Cryptic Apps. All rights reserved.
//

#import "SampleTool.h"
#import <Hopper/HPHopperServices.h>
#import <Hopper/HPDocument.h>

@implementation SampleTool {
    NSObject<HPHopperServices> *_services;
}

- (NSArray *)toolMenuDescription {
    return @[
             @{HPM_TITLE: @"Sample Tool Fct1",
               HPM_SELECTOR: @"fct1:"},
             @{HPM_TITLE: @"Sample Tool Menu",
               HPM_SUBMENU: @[
                       @{HPM_TITLE: @"Fct 2",
                         HPM_SELECTOR: @"fct2:"},
                       @{HPM_TITLE: @"Fct 3",
                         HPM_SELECTOR: @"fct3:"}
                     ]
               }
             ];
}

- (void)fct1:(id)sender {
    NSObject<HPDocument> *doc = [_services currentDocument];
    [doc beginToWait:@"I'm waiting…"];
    NSString *msg = [NSString stringWithFormat:@"Function1: address is 0x%llx", [doc currentAddress]];
    [doc displayAlertWithMessageText:@"Info"
                       defaultButton:@"OK"
                     alternateButton:nil
                         otherButton:nil
                     informativeText:msg];
    [doc endWaiting];
}

- (void)fct2:(id)sender {
    NSObject<HPDocument> *doc = [_services currentDocument];
    [doc displayAlertWithMessageText:@"Info"
                       defaultButton:@"OK"
                     alternateButton:nil
                         otherButton:nil
                     informativeText:@"Function 2 triggered"];
}

- (void)fct3:(id)sender {
    NSObject<HPDocument> *doc = [_services currentDocument];
    [doc logStringMessage:@"Function 3 triggered"];
}

+ (int)sdkVersion {
    return HOPPER_CURRENT_SDK_VERSION;
}

- (instancetype)initWithHopperServices:(NSObject <HPHopperServices> *)services {
    if (self = [super init]) {
        _services = services;
    }
    return self;
}

- (HopperUUID *)pluginUUID {
    return [_services UUIDWithString:@"b2bbe202-3add-4f70-99c2-3682778bb078"];
}

- (HopperPluginType)pluginType {
    return Plugin_Tool;
}

- (NSString *)pluginName {
    return @"SampleTool";
}

- (NSString *)pluginDescription {
    return @"Sample Tool";
}

- (NSString *)pluginAuthor {
    return @"Vincent Bénony";
}

- (NSString *)pluginCopyright {
    return @"© Cryptic Apps SARL";
}

- (NSString *)commandLineIdentifier {
    return @"DummyTool";
}

- (NSString *)pluginVersion {
    return @"0.0.2";
}

@end
