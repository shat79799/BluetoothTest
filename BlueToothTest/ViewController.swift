//
//  ViewController.swift
//  BlueToothTest
//
//  Created by Stan Liu on 2022/7/16.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    var centralManager: CBCentralManager?
    let serviceUUID = "1fee6acf-a826-4e37-9635-4d8a01642c5d"
    let characteristicUUID = "7691b78a-9015-4367-9b95-fc631c412cc6"
    var peripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
    }
    
    @IBAction func onStartButtonClicked(_ sender: Any) {
        startScanning()
    }
    
    @IBAction func onStopButtonClicked(_ sender: Any) {
        stopScanning()
    }
    
    func setup() {
        let queue: DispatchQueue = DispatchQueue(label: "com.stan.bluetooth", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    func startScanning() {
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("state: unknown")
        case .unsupported:
            print("state: unsupported")
        case .unauthorized:
            print("state: unauthorized")
        case .resetting:
            print("state: resetting")
        case .poweredOn:
            print("state: poweredOn")
        case .poweredOff:
            print("state: poweredOff")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discover: peripheral: \(peripheral), advertisementData: \(advertisementData), rssi: \(RSSI)")
        
        if peripheral.identifier.uuidString == serviceUUID {
            self.peripheral = peripheral
            centralManager?.connect(self.peripheral!)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect success: \(peripheral)")
        stopScanning()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did connect failure: \(peripheral), error: \(error)")
    }
    
}

extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("discover services, error: \(error)")
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            print("discover services: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("discover characteristics, error: \(error)")
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("discover characteristic: \(characteristic)")
            if characteristic.uuid.uuidString.lowercased() == characteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                print("found battery: \(characteristic)")
            }
        }
    }
    
}
