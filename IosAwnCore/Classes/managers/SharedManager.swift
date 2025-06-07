//
//  SharedManager.swift
//  awesome_notifications
//
//  Created by Rafael Setragni on 11/09/20.
//

import Foundation

public class SharedManager {
    
    let _userDefaults = UserDefaults(suiteName: Definitions.USER_DEFAULT_TAG)
    
    let tag:String
    var objectList:[String:Any?]    
    
    public init(tag:String){
        self.tag = tag
        objectList = _userDefaults!.dictionary(forKey: tag) ?? [:]
    }
    
    private let TAG:String = "SharedManager"
    
    private func refreshObjects(){
         guard let userDefaults = _userDefaults else {
            Logger.shared.d("ELFIE","UserDefaults not available")
            return
        }
        objectList = userDefaults.dictionary(forKey: tag) ?? [:]
     }
    
    private func updateObjects(){
        guard let userDefaults = _userDefaults else {
            Logger.shared.d("ELFIE","UserDefaults not available")
            return
        }
        userDefaults.removeObject(forKey: tag)
        userDefaults.setValue(objectList, forKey: tag)
        refreshObjects()
    }
    
    public func get(referenceKey:String ) -> [String:Any?]? {
        refreshObjects()
        return objectList[referenceKey] as? [String:Any?]
    }
    
    public func set(_ data:[String:Any?]?, referenceKey:String) {
        refreshObjects()
        if(StringUtils.shared.isNullOrEmpty(referenceKey) || data == nil){ return }
        if let unwrappedData = data {
            objectList[referenceKey] = unwrappedData
        }
        updateObjects()
    }
    
    public func remove(referenceKey:String) -> Bool {
        refreshObjects()
        if(StringUtils.shared.isNullOrEmpty(referenceKey)){ return false }
        
        if let _ = objectList[referenceKey] {
            objectList.removeValue(forKey: referenceKey)
        }
        updateObjects()
        return true
    }
    
    public func removeAll() {
        refreshObjects()
        objectList.removeAll()
        updateObjects()
    }
    
    public func getAllObjectsStarting(with keyFragment:String) -> [[String:Any?]] {
        refreshObjects()
        var returnedList:[[String:Any?]] = []
        
        for (_, data) in objectList {
            if let dictionary = data as? [String:Any?] {
                // Create a new dictionary to avoid memory alignment issues
                let safeDictionary = dictionary.mapValues { $0 }
                returnedList.append(safeDictionary)
            }
        }
        
        return returnedList
    }
    
    public func getAllObjects() -> [[String:Any?]] {
        refreshObjects()
        var returnedList:[[String:Any?]] = []
        
        for (_, data) in objectList {
            if let dictionary:[String:Any?] = data as? [String:Any?] {
                returnedList.append( dictionary )
            }
        }
        
        return returnedList
    }
    
}
