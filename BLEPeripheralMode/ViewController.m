//
//  ViewController.m
//  BLEPeripheralMode
//
//  Created by qq on 9/8/2016.
//  Copyright © 2016 GitHub. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

// uuidgen
#define kServiceUUID @"6BC6543C-2398-4E4A-AF28-E4E0BF58D6BC"
#define kCharacteristicReadUUID @"9D69C18C-186C-45EA-A7DA-6ED7500E9C97"
#define kCharacteristicWriteUUID @"F973A2FB-36E0-4CA1-A053-8311F0C23CA2"

@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) CBMutableCharacteristic *characteristicRead;
@property (nonatomic, strong) CBMutableCharacteristic *characteristicWrite;

@property (nonatomic, strong) CBCentral *subscribedCentral;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)setupService {
    CBUUID *characteristicReadUUID = [CBUUID UUIDWithString:kCharacteristicReadUUID];
    self.characteristicRead = [[CBMutableCharacteristic alloc] initWithType:characteristicReadUUID
                                                                 properties:CBCharacteristicPropertyRead|
                               CBCharacteristicPropertyNotify|
                               CBCharacteristicPropertyWrite|
                               CBCharacteristicPropertyWriteWithoutResponse
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadable|
                               CBAttributePermissionsWriteable];
    
    CBUUID *characteristicWriteUUID = [CBUUID UUIDWithString:kCharacteristicWriteUUID];
    self.characteristicWrite = [[CBMutableCharacteristic alloc] initWithType:characteristicWriteUUID
                                                                  properties:CBCharacteristicPropertyRead|
                                CBCharacteristicPropertyNotify|
                                CBCharacteristicPropertyWrite|
                                CBCharacteristicPropertyWriteWithoutResponse
                                                                       value:nil
                                                                 permissions:CBAttributePermissionsReadable|
                                CBAttributePermissionsWriteable];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    self.service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    self.service.characteristics = @[self.characteristicRead, self.characteristicWrite];
    
    [self.peripheralManager addService:self.service];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            
            break;
            
        case CBPeripheralManagerStateResetting:
            
            break;
            
        case CBPeripheralManagerStateUnsupported:
            
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            
            break;
            
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            break;
            
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
    if (!error) {
        NSLog(@"didAddService: %@", service);
        
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[self.service.UUID]}];
    } else {
        NSLog(@"%s, error:%@", __func__, error);
    }
    
    NSLog(@"peripheralManagerDidAddService: %@ %@", service, error);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    if (!error) {
        NSLog(@"DidStartAdvertising: %@", peripheral);
        
    } else {
        NSLog(@"%s, error:%@", __func__, error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    self.subscribedCentral = central;
    
    NSLog(@"didSubscribeToCharacteristic: %@, %@", central.identifier, characteristic.UUID);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    //    self.subscribedCentral = nil;
    
    NSLog(@"didSubscribeToCharacteristic: %@, %@", central.identifier, characteristic.UUID);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests[0];
    
    if ([request.characteristic.UUID isEqual:self.characteristicRead.UUID]) {
        
        NSLog(@"%@", request.value);
        
        [peripheral updateValue:request.value forCharacteristic:self.characteristicWrite onSubscribedCentrals:nil];
        
    } else if ([request.characteristic.UUID isEqual:self.characteristicWrite.UUID]) {
        
        //        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
}

@end
