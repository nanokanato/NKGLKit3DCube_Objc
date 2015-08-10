//
//  AppDelegate.m
//  NKGLKit3DCube
//
//  Created by nanoka____ on 2015/08/05.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"

/*========================================================
 ; AppDelegate
 ========================================================*/
@implementation AppDelegate

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc {
    self.window = nil;
}

/*--------------------------------------------------------
 ; didFinishLaunchingWithOptions : アプリ起動
 ;                            in : (UIApplication *)application
 ;                               : (NSDictionary *)launchOptions
 ;                               :
 ;                           out :
 --------------------------------------------------------*/
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    GameViewController *oGameViewController = [[GameViewController alloc] init];
    self.window.rootViewController = oGameViewController;
    oGameViewController = nil;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
