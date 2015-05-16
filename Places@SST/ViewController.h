//
//  ViewController.h
//  Places@SST
//
//  Created by Pan Ziyue on 20/9/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, CBCentralManagerDelegate>

// Managers
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property CLProximity lastProximity;

// UI Elements
@property (weak, nonatomic) IBOutlet UILabel *inferredLocation;
@property (weak, nonatomic) IBOutlet UITextView *inferredInfo;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIImageView *signalIndicator;
@property NSString *lastUsedImage;

@end
