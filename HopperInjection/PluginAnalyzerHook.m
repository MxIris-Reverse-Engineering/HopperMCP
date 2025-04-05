//
//  PluginAnalyzerHook.m
//  HopperInjection
//
//  Created by JH on 2025/4/3.
//

#import "PluginAnalyzerHook.h"
#import <objc/runtime.h>

@interface PluginAnalyzer : NSObject

+ (void)interposeImageAt:(id)a0;
+ (id)loadedDylibs:(id)a0;
+ (id)importedSymbols:(id)a0;
+ (BOOL)pluginContainsIllegalInstructions:(id)a0;
+ (BOOL)pluginIsSafe:(id)a0 error:(NSError **)a1;

@end

@interface ToolFactory : NSObject

+ (id)sharedInstance;
+ (void)loadPlugins;
+ (void)loadPluginsIncludingUserPlugins:(BOOL)a0;
+ (id)toolsSearchPaths;
+ (id)userToolsPath;
+ (id)loadedPlugins;
+ (id)JSONDescriptionOfTools;
+ (id)pluginForUUID:(id)a0;
+ (BOOL)invokeSelector:(id)a0 onPluginUUIDString:(id)a1;

- (void)loadPluginsIncludingUserPlugins:(BOOL)a0;
- (id)loadedPlugins;
- (void)invokePlugin:(id)a0;
- (id)buildMenuForDesc:(id)a0 forPlugin:(id)a1;
- (void)buildMenu;

@end
@implementation PluginAnalyzerHook

+ (void)load {


    Class PluginAnalyzerClass = NSClassFromString(@"PluginAnalyzer");

    method_exchangeImplementations(
                                   class_getClassMethod(PluginAnalyzerClass, @selector(pluginIsSafe:error:)),
                                   class_getClassMethod([self class], @selector(pluginIsSafe:error:))
                                   );
    method_exchangeImplementations(
                                   class_getClassMethod(PluginAnalyzerClass, @selector(pluginContainsIllegalInstructions:)),
                                   class_getClassMethod([self class], @selector(pluginContainsIllegalInstructions:))
                                   );
    method_exchangeImplementations(
                                   class_getClassMethod(PluginAnalyzerClass, @selector(interposeImageAt:)),
                                   class_getClassMethod([self class], @selector(interposeImageAt:))
                                   );
    dispatch_async(dispatch_get_main_queue(), ^{
        Class ToolFactoryClass = NSClassFromString(@"ToolFactory");
        [ToolFactoryClass performSelector:@selector(loadPluginsIncludingUserPlugins:) withObject:@YES];
    });
}


+ (BOOL)pluginIsSafe:(id)a0 error:(NSError **)a1 {
    return YES;
}

+ (BOOL)pluginContainsIllegalInstructions:(id)a0 {
    return NO;
}

+ (void)interposeImageAt:(id)a0 {}

@end
