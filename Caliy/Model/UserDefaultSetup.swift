//
//  UserDefaultSetup.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/21.
//  Copyright © 2020 hanmok. All rights reserved.
//

import Foundation
struct UserDefaultSetup{
    
    let defaults = UserDefaults.standard
    
    enum UserDefaultKey : String{
        case isSoundOnKey
        case isLightModeOnKey
        case isNotificationOnKey
        case isUserEverChangedKey
        case userDeviceSizeInfoKey
        case numberReviewClickedKey
        case userDeviceVersionInfoKey
        case userDeviceVersionTypeInfoKey
    }
    
    
    func setIsSoundOn(isSoundOn : Bool){
        
        defaults.set(isSoundOn,forKey: UserDefaultKey.isSoundOnKey.rawValue)
    }
    
    func setIsLightModeOn(isLightModeOn : Bool){
        
        defaults.set(isLightModeOn,forKey: UserDefaultKey.isLightModeOnKey.rawValue)
    }
    
    func setIsNotificationOn(isNotificationOn : Bool){
        
        defaults.set(isNotificationOn,forKey: UserDefaultKey.isNotificationOnKey.rawValue)
    }
    
    func setNumberReviewClicked(numberReviewClicked : Int){
        defaults.set(numberReviewClicked, forKey: UserDefaultKey.numberReviewClickedKey.rawValue)
    }
    
    func setUserDeviceSizeInfo(userDeviceSizeInfo : String){
        defaults.set(userDeviceSizeInfo, forKey: UserDefaultKey.userDeviceSizeInfoKey.rawValue)
    }
    
    func setUserDeviceVersionInfo(userDeviceVersionInfo : String){
        defaults.set(userDeviceVersionInfo, forKey: UserDefaultKey.userDeviceVersionInfoKey.rawValue)
    }
    func setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo : String){
        defaults.set(userDeviceVersionTypeInfo, forKey: UserDefaultKey.userDeviceVersionTypeInfoKey.rawValue)
    }
    
    
    
    func getIsSoundOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.isSoundOnKey.rawValue)
    }
    
    func getIsLightModeOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.isLightModeOnKey.rawValue)
    }
    
    func getIsNotificationOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.isNotificationOnKey.rawValue)
    }
    
    func getNumberReviewClicked() -> Int{
        return defaults.integer(forKey: UserDefaultKey.numberReviewClickedKey.rawValue)
    }
    
    func getUserDeviceSizeInfo() -> String{
        return defaults.string(forKey: UserDefaultKey.userDeviceSizeInfoKey.rawValue) ?? "A"
    }
    func getUserDeviceVersionInfo() -> String{
        return defaults.string(forKey: UserDefaultKey.userDeviceVersionInfoKey.rawValue) ?? "ND"
    }
    func getUserDeviceVersionTypeInfo() -> String{
        return defaults.string(forKey: UserDefaultKey.userDeviceVersionTypeInfoKey.rawValue) ?? "What"
    }
    
    //ND stands for Not Determined.
    // MP : Most popular, P : Popular, LP : Least Popular
    
    
    func setIsUserEverChanged(isUserEverChanged : Bool){
        defaults.set(isUserEverChanged, forKey: UserDefaultKey.isUserEverChangedKey.rawValue)
    }
    
    func getIsUserEverChanged() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.isUserEverChangedKey.rawValue)
    }
}
