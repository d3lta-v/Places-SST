//
//  ViewController.m
//  Places@SST
//
//  Created by Pan Ziyue on 20/9/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import "ViewController.h"
#import "NoBluetoothViewController.h"
#import "PlacesKit.h"

#define kDefaultFontSize 75.0

@interface ViewController ()
{
    NSString *locationString;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _inferredLocation.adjustsFontSizeToFitWidth = YES;
    _inferredLocation.numberOfLines = 1;
    
    _signalIndicator.image = [PlacesKit imageOfCanvas1];
    
    //TODO: Turn off all BL functionality UNTIL UI is finished
    /*
    // Check if bluetooth is on or off
    [self startBluetoothStatusMonitoring];
    
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"775752A9-F236-4619-9562-84AC9DE124C6"];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"Estimote Region"];
    
    // Start monitoring
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];*/
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
            // No beacons are in range
            _signalStrength.text = @"No Signal";
            _inferredLocation.text = @"You are not in SST";
            _inferredInfo.text = @"You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
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
            /*switch (foundBeacon.proximity) {
                case 1:
                    _signalStrength.text = @"Strong";
                    _signalIndicator.image = [PlacesKit imageOfCanvas1];
                    break;
                case 2:
                    _signalStrength.text = @"Average";
                    _signalIndicator.image = [PlacesKit imageOfCanvas2];
                    break;
                case 3:
                    _signalStrength.text = @"Weak";
                    _signalIndicator.image = [PlacesKit imageOfCanvas3];
                    break;
                default:
                    _signalStrength.text = @"Very Weak";
                    _signalIndicator.image = [PlacesKit imageOfCanvas3];
                    break;
            }*/
            if (foundBeacon.proximity == CLProximityImmediate) {
                _signalIndicator.image = [PlacesKit imageOfCanvas1];
            } else if (foundBeacon.proximity == CLProximityNear) {
                _signalIndicator.image = [PlacesKit imageOfCanvas1];
            } else if (foundBeacon.proximity == CLProximityFar) {
                _signalIndicator.image = [PlacesKit imageOfCanvas2];
            } else if (foundBeacon.proximity == CLProximityUnknown) {
                _signalIndicator.image = [PlacesKit imageOfCanvas3];
            }
            
            // Call the function to automatically set the text
            [self setTextInfoWithMajor:major minor:minor];
        }
    } else {
        // Still in region but no good lock on to beacon
        //_signalStrength.text = @"No Signal";
        //_inferredLocation.text = @"You are not in SST";
        //_inferredInfo.text = @"You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
    }
}

// This will set the text and images accordingly
-(void)setTextInfoWithMajor:(NSString *)major minor:(NSString *)minor
{
    locationString = [[NSString alloc] init];
    
    // Admin block
    if ([major isEqual:@"1"]) {
        //locationString = [locationString stringByAppendingString:@"Admin Block, "];
        if ([minor isEqual:@"1"]) {
            locationString = [locationString stringByAppendingString:@"SST Wall"];
            _inferredInfo.text = @"This is the SST Wall, the most iconic place in the whole of SST.";
        }
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"Integrated "];
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
        //locationString = [locationString stringByAppendingString:@"Block B, "];
        if ([minor isEqual:@"1"])
            locationString = [locationString stringByAppendingString:@"Visitor Centre"];
        else if ([minor isEqual:@"2"]){
            locationString = [locationString stringByAppendingString:@"Exhibition Centre"];
            [UIView transitionWithView:_bgImg duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{_bgImg.image = [UIImage imageNamed:@"ExhibitionStudioDefault"];} completion:nil];
            _inferredInfo.text = @"The Exhibition Center is a place for students and the school to showcase their works and achievements, ranging from art pieces to outstanding ISS (Interdisciplinary Science Studies) projects. This place houses the school's various achievements.";
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
        //locationString = [locationString stringByAppendingString:@"Block C, "];
        if ([minor isEqual:@"1"]) {
            [UIView transitionWithView:_inferredImage duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{_inferredImage.image = [UIImage imageNamed:@"ScienceHub"];} completion:nil];
            locationString = [locationString stringByAppendingString:@"Science Hub"];
            _inferredInfo.text = @"Opportunities for independent and joint research experimentation abound in our state-of-the-art Science Hub, which comprises twelve laboratories (four dedicated to the Applied Sciences), as well as a tissue culture room, a research lab and an engineering lab.\nThe unique multifunctional NAWIS® system in the Physics laboratories allows for more flexibility and mobility in these spaces. Special research equipment are also available in the laboratories to support students’ explorations in the fields of Analytical Chemistry, Biomedical Sciences and Sensor Technology.";
        }
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"Makerspace"];
            [UIView transitionWithView:_bgImg duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{_bgImg.image = [UIImage imageNamed:@"CanteenDefault"];} completion:nil];
            _inferredInfo.text = @"The SST Makerspace is a fully-equipped learning zone where students can design, prototype and manufacture products. Makerspaces are a fairly new phenomenon, but are beginning to make waves in the field of education. The SST Makerspace represents the democratisation of design, engineering, fabrication and education, and empowers our students with the resources to unleash their creativity.";
        }
        else if ([minor isEqual:@"3"]) {
            locationString = [locationString stringByAppendingString:@"Beta Labs"];
            _inferredInfo.text = @"The Beta Lab is a new generation classroom concept of what a future classroom should be like. Currently adopted in tertiary institutes in Singapore, the room facilitates collaboration and small group discussions due to the integration of technology within its layout.";
        }
        else if ([minor isEqual:@"4"]) {
            locationString = [locationString stringByAppendingString:@"Robotics Room"];
            _inferredInfo.text = @"";
        }
        else
            locationString=@"Polling for signals...";
    }
    // Sports complex
    else if ([major isEqual:@"4"]) {
        locationString = [locationString stringByAppendingString:@"Sports Complex"];
        _inferredInfo.text = @"The Ngee Ann Kongsi Sports Complex consists of a multi-purpose hall, an indoor sports hall, gym, dance studio, music room and a rooftop basketball court cum running track. Outdoor sports facilities include a synthetic football field and a NAPFA fitness area, in addition to three CCA rooms and a student leader lounge.";
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

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
