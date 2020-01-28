//
//  AppDelegate.swift
//  CabinAR
//
//  Created by Pascal Rettig on 2/26/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var userInfo: UserInfo?
    var reloadScene: Bool = true
    
    func setUser(_ userInfo: UserInfo) {
        self.userInfo = userInfo
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
            ], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .selected)
        
      
        return true
    }
    
    func application(_ application: UIApplication,
                        open url: URL,
                        options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
           
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
           let action = components.host,
           let params = components.queryItems else {
               print("Invalid URL")
               return false
        }
        
        if action == "space" {
            if let cabin_key = params.first(where: { $0.name == "cabin_key" })?.value,
                let space_id = params.first(where: { $0.name == "space_id" })?.value {
                
                CabinARApi.api.getSpace(Int(space_id) ?? 0, api_key: cabin_key) { fetchedSpace in
                    let mySpace = fetchedSpace
                    
                    // Remove any nested controller
                    let navigationController = self.window?.rootViewController as! UINavigationController?
                    
                    navigationController!.popToRootViewController(animated: false)
                       
                    let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                    let spaceController = storyBoard.instantiateViewController(withIdentifier: "space_view_controller") as! SpaceViewController
                
                    if mySpace != nil {
                        spaceController.space = mySpace
                        spaceController.api_key = cabin_key
                        navigationController!.pushViewController(spaceController, animated:true)
                    }
                }
            }

        }
        
        
       
       return false
   }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

