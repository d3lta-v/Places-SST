//
//  AppDelegate.m
//  Places@SST
//
//  Created by Pan Ziyue on 20/9/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set status bar color to white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set UINavigationBar colors
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Initializes tab bar customization
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]]; // Tab bar SELECTED color
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:(64.0/255.0) green:(164.0/255.0) blue:(231.0/255.0) alpha:1]]; // Tab bar BACKGROUND color
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:71.0/255.0 green:82.0/255.0 blue:93.0/255.0 alpha:1]} forState:UIControlStateNormal]; // Tab bar ITEM DESELECTED TEXT color
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected]; // Tab bar ITEM SELECTED TEXT color
    // Custom UITabBarController code here
    self.tabBarController = (UITabBarController*)self.window.rootViewController;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    // Image setting
    // Events Tab
    [item0 setImage:[[UIImage imageNamed:@"EventsTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item0 setSelectedImage:[[UIImage imageNamed:@"EventsTabSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    // Here Tab
    [item1 setImage:[[UIImage imageNamed:@"HereTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item1 setSelectedImage:[[UIImage imageNamed:@"HereTabSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    // About Tab
    [item2 setImage:[[UIImage imageNamed:@"AboutTab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item2 setSelectedImage:[[UIImage imageNamed:@"AboutTabSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    // Sets the default tab to index 1 (or 2nd tab)
    self.tabBarController.selectedIndex = 1;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
