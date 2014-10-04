//
//  PeripheralStore.swift
//  BlueCap
//
//  Created by Troy Stribling on 8/10/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation
import BlueCapKit
import CoreBluetooth

class PeripheralStore {
    
    // services
    class func getPeripheralServices(key:String) -> [String:[CBUUID]] {
        if let storedPeripherals = NSUserDefaults.standardUserDefaults().dictionaryForKey(key) {
            var peripherals = [String:[CBUUID]]()
            for (name, services) in storedPeripherals {
                if let name = name as? String {
                    if let services = services as? [String] {
                        let uuids = services.reduce([CBUUID]()){(uuids, uuidString) in
                            if let uuid = CBUUID.UUIDWithString(uuidString) {
                                return uuids + [uuid]
                            } else {
                                return uuids
                            }
                        }
                        peripherals[name] = uuids
                    }
                }
            }
            return peripherals
        } else {
            return [:]
        }
    }

    class func setPeripheralServices(key:String, peripheralServices:[String:[CBUUID]]) {
        var storedPeripherals = [String:[String]]()
        for (name, uuids) in peripheralServices {
            storedPeripherals[name] = uuids.reduce([String]()) {(storedUUIDs, uuid) in
                if let storedUUID = uuid.UUIDString {
                    return storedUUIDs + [storedUUID]
                } else {
                    return storedUUIDs
                }
            }
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(storedPeripherals, forKey:key)
    }
    
    // peripheral supported services
    class func addPeripheralServices(name:String, services:[CBUUID]) {
        var peripherals = self.getPeripheralServices("peripheralServices")
        peripherals[name] = services
        self.setPeripheralServices("peripheralServices", peripheralServices:peripherals)
    }
    
    class func addPeripheralService(name:String, service:CBUUID) {
        var peripheralServices = self.getPeripheralServices("peripheralServices")
        if let services = peripheralServices[name] {
            peripheralServices[name] = services + [service]
        } else {
            peripheralServices[name] = [service]
        }
        self.setPeripheralServices("peripheralServices", peripheralServices:peripheralServices)
    }
    
    class func removePeripheralService(name:String, service:CBUUID) {
        var peripherals = self.getPeripheralServices("peripheralServices")
        if let services = peripherals[name] {
            peripherals[name] = services.filter{$0 != service}
        }
        self.setPeripheralServices("peripheralServices", peripheralServices:peripherals)
    }
    
    class func removePeripheralServices(name:String) {
        var peripheralServices = self.getPeripheralServices("peripheralServices")
        peripheralServices.removeValueForKey(name)
        self.setPeripheralServices("peripheralServices", peripheralServices:peripheralServices)
    }

    class func getPeripheralServicesForPeripheral(peripheral:String) -> [CBUUID] {
        var peripheralServices = self.getPeripheralServices("peripheralServices")
        if let services = peripheralServices[peripheral] {
            return services
        } else {
            return []
        }
    }
    
    // advertised peripheral services
    class func getAdvertisedPeripheralServices() -> [String:[CBUUID]] {
        return self.getPeripheralServices("advertisedPeripheralServices")
    }
    
    class func addAdvertisedPeripheralServices(name:String, services:[CBUUID]) {
        var peripherals = self.getPeripheralServices("advertisedPeripheralServices")
        peripherals[name] = services
        self.setPeripheralServices("advertisedPeripheralServices", peripheralServices:peripherals)
    }
    
    class func addAdvertisedPeripheralService(name:String, service:CBUUID) {
        var peripheralServices = self.getPeripheralServices("advertisedPeripheralServices")
        if let services = peripheralServices[name] {
            peripheralServices[name] = services + [service]
        } else {
            peripheralServices[name] = [service]
        }
        self.setPeripheralServices("advertisedPeripheralServices", peripheralServices:peripheralServices)
    }
    
    class func removeAdvertisedPeripheralService(name:String, service:CBUUID) {
        Logger.debug("PeripheralStore#removeAdvertisedPeripheralService \(name), \(service)")
        var peripherals = self.getPeripheralServices("advertisedPeripheralServices")
        Logger.debug("PeripheralStore#removeAdvertisedPeripheralService \(peripherals)")
        if let services = peripherals[name] {
            Logger.debug("PeripheralStore#removeAdvertisedPeripheralService \(services)")
            peripherals[name] = services.filter{$0 != service}
            Logger.debug("PeripheralStore#removeAdvertisedPeripheralService \(services)")
        }
        Logger.debug("PeripheralStore#removeAdvertisedPeripheralService \(peripherals)")
        self.setPeripheralServices("advertisedPeripheralServices", peripheralServices:peripherals)
    }
    
    class func removeAdvertisedPeripheralServices(name:String) {
        var peripheralServices = self.getPeripheralServices("advertisedPeripheralServices")
        peripheralServices.removeValueForKey(name)
        self.setPeripheralServices("advertisedPeripheralServices", peripheralServices:peripheralServices)
    }

    class func getAdvertisedPeripheralServicesForPeripheral(peripheral:String) -> [CBUUID] {
        var peripheralServices = self.getPeripheralServices("advertisedPeripheralServices")
        if let services = peripheralServices[peripheral] {
            return services
        } else {
            return []
        }
    }

    // periphearl names
    class func getPeripheralNames() -> [String] {
        if let peripheral = NSUserDefaults.standardUserDefaults().arrayForKey("peripheralNames") {
            return peripheral.map{$0 as String}
        } else {
            return []
        }
    }

    class func setPeripheralNames(names:[String]) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(names, forKey:"peripheralNames")
    }
    
    class func addPeripheralName(name:String) {
        var names = self.getPeripheralNames()
        self.setPeripheralNames(names + [name])
    }
    
    class func removePeripheralName(name:String) {
        var names = self.getPeripheralNames()
        self.setPeripheralNames(names.filter{$0 != name})
    }
    
    // peripheral
    class func removePeripheral(name:String) {
        self.removePeripheralServices(name)
        self.removePeripheralName(name)
        self.removeAdvertisedPeripheralServices(name)
        self.removeAdvertisedBeacon(name)
        self.removeBeaconEnabled(name)
    }
    
    // ibeacon
    class func getAdvertisedBeacons() -> [String:String] {
        var beacons : [String:String] = [:]
        if let storedBeacons = NSUserDefaults.standardUserDefaults().dictionaryForKey("peripheralAdvertisedBeaconConfigs") {
            for (peripheral, beacon) in storedBeacons {
                if let peripheral = peripheral as? String {
                    if let beacon = beacon as? String {
                        beacons[peripheral] = beacon
                    }
                }
            }
            return beacons
        } else {
            return [:]
        }
    }
    
    class func setAdvertisedBeacons(beacons:[String:String]) {
        NSUserDefaults.standardUserDefaults().setObject(beacons, forKey:"peripheralAdvertisedBeaconConfigs")
    }
    
    class func getAdvertisedBeacon(peripheral:String) -> String? {
        let beacons = self.getAdvertisedBeacons()
        return beacons[peripheral]
    }
    
    class func setAdvertisedBeacon(peripheral:String, beacon:String) {
        var beacons = getAdvertisedBeacons()
        beacons[peripheral] = beacon
        self.setAdvertisedBeacons(beacons)
    }
    
    class func removeAdvertisedBeacon(peripheral:String) {
        var beacons = getAdvertisedBeacons()
        beacons.removeValueForKey(peripheral)
        self.setAdvertisedBeacons(beacons)
    }
    
    // ibeacon enabled
    class func getBeaconsEnabled() -> [String:Bool] {
        var beacons = [String:Bool]()
        if let storedBeacons = NSUserDefaults.standardUserDefaults().dictionaryForKey("peipheralBeaconsEnabled") {
            for (peripheral, enabled) in storedBeacons {
                if let peripheral = peripheral as? String {
                    if let enabled = enabled as? NSNumber {
                        beacons[peripheral] = enabled.boolValue
                    }
                }
            }
            return beacons
        } else {
            return [:]
        }
    }
    
    class func setBeaconsEnabled(beacons:[String:Bool]) {
        var storedBeacons = [String:NSNumber]()
        for (periheral, enabled) in beacons {
            storedBeacons[periheral] = NSNumber(bool:enabled)
        }
        NSUserDefaults.standardUserDefaults().setObject(storedBeacons, forKey:"peipheralBeaconsEnabled")
    }
    
    class func getBeaconEnabled(peripheral:String) -> Bool {
        let beacons = self.getBeaconsEnabled()
        if let enabled = beacons[peripheral] {
            return (enabled as NSNumber).boolValue
        } else {
            return false
        }
    }

    class func setBeaconEnabled(peripheral:String, enabled:Bool) {
        var beacons = self.getBeaconsEnabled()
        beacons[peripheral] = enabled
        self.setBeaconsEnabled(beacons)
    }
    
    class func removeBeaconEnabled(peripheral:String) {
        var beacons = self.getBeaconsEnabled()
        beacons.removeValueForKey(peripheral)
        self.setBeaconsEnabled(beacons)
    }

    // peripheral beacon
    class func getBeacons() -> [String:NSUUID] {
        if let storedBeacons = NSUserDefaults.standardUserDefaults().dictionaryForKey("peripheralBeacons") {
            var beacons = [String:NSUUID]()
            for (name, uuid) in storedBeacons {
                if let name = name as? String {
                    if let uuid = uuid as? String {
                        beacons[name] = NSUUID(UUIDString:uuid)
                    }
                }
            }
            return beacons
        } else {
            return [:]
        }
    }
    
    class func setBeacons(beacons:[String:NSUUID]) {
        var storedBeacons = [String:String]()
        for (name, uuid) in beacons {
            storedBeacons[name] = uuid.UUIDString
        }
        NSUserDefaults.standardUserDefaults().setObject(storedBeacons, forKey:"peripheralBeacons")
    }
    
    class func getBeaconNames() -> [String] {
        return self.getBeacons().keys.array
    }
    
    class func addBeacon(name:String, uuid:NSUUID) {
        var beacons = self.getBeacons()
        beacons[name] = uuid
        self.setBeacons(beacons)
    }
    
    class func removeBeacon(name:String) {
        var beacons = self.getBeacons()
        beacons.removeValueForKey(name)
        self.setBeacons(beacons)
    }
    
    class func getBeacon(name:String) -> NSUUID? {
        let beacons = self.getBeacons()
        return beacons[name]
    }
    
    class func getBeaconConfigs() -> [String:[Int]] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let storedConfigs = userDefaults.dictionaryForKey("peipheralBeaconConfigs") {
            var configs = [String:[Int]]()
            for (name, config) in storedConfigs {
                if let name = name as? String {
                    if config.count == 2 {
                        let major = config[0] as NSNumber
                        let minor = config[1] as NSNumber
                        configs[name] = [major, minor]
                    }
                }
            }
            return configs
        } else {
            return [:]
        }
    }
    
    class func setBeaconConfigs(configs:[String:[Int]]) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var storeConfigs = [String:[NSNumber]]()
        for (name, config) in configs {
            storeConfigs[name] = [NSNumber(integer:config[0]), NSNumber(integer:config[1])]
        }
        userDefaults.setObject(storeConfigs, forKey:"peipheralBeaconConfigs")
    }
    
    class func addBeaconConfig(name:String, config:[Int]) {
        var configs = self.getBeaconConfigs()
        configs[name] = config
        self.setBeaconConfigs(configs)
    }
    
    class func getBeaconConfig(name:String) -> [Int] {
        let configs = self.getBeaconConfigs()
        if let config = configs[name] {
            return config
        } else {
            return [0,0]
        }
    }
    
    class func removeBeaconConfig(name:String) {
        var configs = self.getBeaconConfigs()
        configs.removeValueForKey(name)
        self.setBeaconConfigs(configs)
    }
    

}
