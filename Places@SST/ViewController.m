//
//  ViewController.m
//  Places@SST
//
//  Created by Pan Ziyue on 20/9/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import "ViewController.h"
#import "NoBluetoothViewController.h"

@interface ViewController ()
{
    NSString *locationString;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Check if bluetooth is on or off
    [self startBluetoothStatusMonitoring];
    
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"775752A9-F236-4619-9562-84AC9DE124C6"];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"Estimote Region"];
    
    // Start monitoring
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager delegate

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
            break;
        case CLRegionStateOutside:
            NSLog(@"outside");
        case CLRegionStateUnknown:
        default:
            // stop ranging beacons, etc
            NSLog(@"Region unknown");
    }
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count]>0) {
        // Detect amount of beacons in range
        
        // Get the nearest found beacon
        beacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown]];
        beacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity != %d", -1]];
        //if (beacons.count==0) {
        if (false) {
            
        } else {
            CLBeacon *foundBeacon = [beacons firstObject];
            
            // All the beacon parameters here
            //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
            NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
            NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
            
            // Get proximity
            switch (foundBeacon.proximity) {
                case 1:
                    _signalStrength.text = @"Strong";
                    break;
                case 2:
                    _signalStrength.text = @"Average";
                    break;
                case 3:
                    _signalStrength.text = @"Weak";
                    break;
                default:
                    _signalStrength.text = @"Very Weak";
                    break;
            }
            
            // Call the function to automatically set the text
            [self setTextInfoWithMajor:major minor:minor];
        }
    } else {
        // No beacons are in range
        _signalStrength.text = @"No Signal";
        _inferredLocation.text = @"You are not in SST";
        _inferredInfo.text = @"You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
    }
}

-(void)setTextInfoWithMajor:(NSString *)major minor:(NSString *)minor
{
    locationString = [[NSString alloc] init];
    
    // Admin block
    if ([major isEqual:@"1"]) {
        locationString = [locationString stringByAppendingString:@"Admin Block, "];
        if ([minor isEqual:@"1"])
            locationString = [locationString stringByAppendingString:@"General Office"];
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"Atrium"];
            [UIView transitionWithView:_bgImg
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _bgImg.image = [UIImage imageNamed:@"AtriumDefault"];
                            } completion:nil];
        }
        else
            locationString=@"Polling for signals...";
    }
    // Block B
    else if ([major isEqual:@"2"]) {
        locationString = [locationString stringByAppendingString:@"Block B, "];
        if ([minor isEqual:@"1"])
            locationString = [locationString stringByAppendingString:@"Visitor Centre"];
        else if ([minor isEqual:@"2"]){
            locationString = [locationString stringByAppendingString:@"Exhibition Centre"];
            [UIView transitionWithView:_bgImg
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _bgImg.image = [UIImage imageNamed:@"ExhibitionStudioDefault"];
                            } completion:nil];
        }
        else if ([minor isEqual:@"4"]) {
            locationString = [locationString stringByAppendingString:@"ICT Helpdesk"];
            [UIView transitionWithView:_bgImg
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _bgImg.image = [UIImage imageNamed:@"HelpdeskDefault"];
                            } completion:nil];
        }
        else if ([minor isEqual:@"5"])
            locationString = [locationString stringByAppendingString:@"Café"];
        else
            locationString=@"Polling for signals...";
    }
    // Block C
    else if ([major isEqual:@"3"]) {
        locationString = [locationString stringByAppendingString:@"Block C, "];
        if ([minor isEqual:@"1"])
            locationString = [locationString stringByAppendingString:@"Laboratories"];
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"Canteen"];
            [UIView transitionWithView:_bgImg
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _bgImg.image = [UIImage imageNamed:@"CanteenDefault"];
                            } completion:nil];
            
        }
        else if ([minor isEqual:@"3"])
            locationString = [locationString stringByAppendingString:@"Pond"];
        else
            locationString=@"Polling for signals...";
    }
    // Sports complex
    else if ([major isEqual:@"4"]) {
        locationString = [locationString stringByAppendingString:@"Sports Complex, "];
    }
    else
    {
        locationString = @"Unknown location";
        NSLog(@"%@, %@", major, minor);
    }
    
    // Finally set the text
    _inferredLocation.text = locationString;
}

#pragma mark - CBCentralManager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([central state] == CBCentralManagerStatePoweredOn) {
        //bluetoothEnabled = YES
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        //bluetoothEnabled = NO;
        [self performSegueWithIdentifier:@"NoBluetoothSegue" sender:self];
    }
}

- (void)startBluetoothStatusMonitoring {
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

@end
