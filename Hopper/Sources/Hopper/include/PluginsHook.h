#import <Foundation/Foundation.h>

@interface PluginAnalyzer : NSObject

+ (void)interposeImageAt:(id)a0;
+ (id)loadedDylibs:(id)a0;
+ (id)importedSymbols:(id)a0;
+ (BOOL)pluginContainsIllegalInstructions:(id)a0;
+ (BOOL)pluginIsSafe:(id)a0 error:(NSError **)a1;

@end

@interface ToolFactory : NSObject

+ (instancetype)sharedInstance;
+ (void)loadPlugins;
+ (void)loadPluginsIncludingUserPlugins:(BOOL)includingUserPlugins;
+ (id)toolsSearchPaths;
+ (id)userToolsPath;
+ (id)loadedPlugins;
+ (id)JSONDescriptionOfTools;
+ (id)pluginForUUID:(id)a0;
+ (BOOL)invokeSelector:(id)a0 onPluginUUIDString:(id)a1;

- (void)loadPluginsIncludingUserPlugins:(BOOL)includingUserPlugins;
- (id)loadedPlugins;
- (void)invokePlugin:(id)a0;
- (id)buildMenuForDesc:(id)a0 forPlugin:(id)a1;
- (void)buildMenu;

@end
