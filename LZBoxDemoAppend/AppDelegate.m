//
//  AppDelegate.m
//  LZBoxDemoAppend
//
//  Created by Lay on 2020/5/6.
//  Copyright © 2020 Lay. All rights reserved.
//

#import "AppDelegate.h"
#import <ALLFoundation/BDLifecycleLoader.h>
#import <HBPageRouter.h>
#import <HBNavigationController.h>
#import <HBNavigator.h>

@implementation AppDelegate

#ifdef DEBUG
+ (void)load
{
//    [NSUserDefaults standardUserDefaults][@"DEBUG"] = @YES; // 供业务库调试使用
}
#endif

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BDLifecycleLoader loadLifecycles];
//
//    // 注册 URL Protocol
//    [HBNetworkEngine registerURLProtocolClasses:@[
//                                                  [HBHybridURLProtocol class],
//                                                  [HBWebViewImageCacheProtocol class],
//                                                  [HBHttpDnsURLProtocol class],
//                                                  [HBSVGURLProtocol class],
//                                                  ]];
//
//    [BDNetworkConfig apply];
//
    if ([self.class.superclass instancesRespondToSelector:_cmd]) {
        [super application:application willFinishLaunchingWithOptions:launchOptions];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
//
//    // only create main window when launched from foreground
    if (application.applicationState != UIApplicationStateBackground) {
        [self createMainWindowForApplication:application];
    }
//
//    [self applyLocalFix];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [super applicationWillEnterForeground:application];
//
//    // if the app is launched from background (by system), then create main window for the first time
//    if (self.window == nil) {
//        [self createMainWindowForApplication:application];
//    }
}

- (void)createMainWindowForApplication:(UIApplication *)application
{
    UIViewController *mainViewController = [[HBPageRouter router] matchControllerUrl:@"bb/demo"];

//    [self observeMainScreenDidAppear:mainViewController];
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    HBNavigationController *nav = [[HBNavigationController alloc] initWithRootViewController:mainViewController];
    [[HBNavigator instance] setRootNavigationController:nav];
    self.window.rootViewController = nav;
//    if (fromUserPrivacy) {
//        [[BDSplashAdsWindow sharedInstance] tryShowSplashAds];
//    } else {
////tryShowDefaultSplashView方法如果是从隐私页面点击确定后执行的话会有问题，BDSplashAdsWindow监听了启动的UIApplicationDidBecomeActiveNotification通知来执行tryLaunchSplashAds方法，如果是从隐私过来的，在点击确认之前就已经完成启动的UIApplicationDidBecomeActiveNotification通知，所以BDSplashAdsWindow会一直存在，造成卡死的假象，只有从后台切回前台才会进到首页
//        [[BDSplashAdsWindow sharedInstance] tryShowDefaultSplashView];
//    }

    [self.window makeKeyAndVisible];
}

- (void)registerRemoteNotification
{
//    if ([[Reachability reachabilityForInternetConnection] isReachable]) {
//        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
//    }
}

- (void)applyLocalFix
{
//    if ([HBIOC_Environment isRelease]) {
//        return;
//    }
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"patch" ofType:@"rb"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [[HBHotFixService sharedService] applyPatchScript:script];
}

#pragma mark - mainScreen

- (void)observeMainScreenDidAppear:(UIViewController *)viewController
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationHomeViewControllerDidAppear:) name:kHBBaseViewControllerDidAppearNotification object:viewController];
}

- (void)applicationHomeViewControllerDidAppear:(NSNotification *)notification
{
//    [self triggleApplication:[UIApplication sharedApplication] mainScreenDidFirstAppearLifycycle:notification.object];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHBBaseViewControllerDidAppearNotification object:notification.object];
}

@end
