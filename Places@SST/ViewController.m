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
#import "InAppBrowserViewController.h"

@interface ViewController ()
{
    NSString *locationString;
    NSString *linkURL;
    bool inRegion;
    
    BOOL debugMode;
}

@end

@implementation ViewController

@synthesize iPadIsUsed;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        iPadIsUsed = UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad; // Initialization of a run-time constant
        linkURL = @"";
        self.beaconDisconnectInteger = 0;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug_mode"]==YES) {
            debugMode = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize text and image views
    _inferredLocation.adjustsFontSizeToFitWidth = YES;
    inRegion = false;
    _signalIndicator.image = [self applySignal:0];
    
    // Check if bluetooth is on or off
    [self startBluetoothStatusMonitoring];
    
    
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"775752A9-F236-4619-9562-84AC9DE124C6"];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"Estimote Region"];
    
    self.lastUsedImage = @"SSTGeneric";
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Start monitoring
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    
    // Check for debug mode
    if (debugMode) {
        // Show debug labels
        _rawConnectivity.alpha = 1;
        _rawRSSI.alpha = 1;
        _beaconDisconnectThreshold.alpha = 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager delegate

- (void) locationManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count]>0) {
        // Reset beacon disconnect counter
        self.beaconDisconnectInteger = 0;
        
        // Get the nearest found beacon
        CLBeacon *foundBeacon = [beacons firstObject];
        
        // All the beacon parameters here
        //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
        NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        
        // Clean up proximity data to prevent jumping to and from CLProximityUnknown
        if(foundBeacon.proximity == self.lastProximity ||
           foundBeacon.proximity == CLProximityUnknown) {
            return;
        }
        
        // Use different signal "Immediate" thresholds for iPad and iPhone, since iPads have better signal sensitivity
        short immediateThreshold;
        if (iPadIsUsed) {
            immediateThreshold = -65;
        } else {
            immediateThreshold = -68;
        }
        
        if (foundBeacon.rssi>=immediateThreshold) {
            _signalIndicator.image = [self applySignal:3];
            if (![linkURL isEqualToString:@""]) {
                // Initiate segue only when linkURL is not empty
                [self performSegueWithIdentifier:@"ShowDetail" sender:self];
            }
        } else {
            if (foundBeacon.rssi>=-80) { // Near
                _signalIndicator.image = [self applySignal:3];
            } else if (foundBeacon.rssi >= -90) { // Medium
                _signalIndicator.image = [self applySignal:2];
            } else if (foundBeacon.rssi >= -110) { // Far
                _signalIndicator.image = [self applySignal:1];
            } else { // Final catching mechanism, just to be safe
                _signalIndicator.image = [self applySignal:1];
            }
        }
        
        // Call the function to automatically set the text
        [self setTextInfoWithMajor:major minor:minor];
        
        if (debugMode) {
            NSLog(@"Beacon detected with %@, %@", major, minor);
            NSLog(@"RSSI: %ld", (long)foundBeacon.rssi);
            _rawConnectivity.text = @"CONNECTED";
            _beaconDisconnectThreshold.text = [NSString stringWithFormat:@"%hd/9", self.beaconDisconnectInteger];
            _rawRSSI.text = [NSString stringWithFormat:@"RSSI: %lddBm", (long)foundBeacon.rssi];
        }
    } else {
        // Beacon count is zero
        
        // Implement smoothing algorithm, by incrementing an NSUInteger (current disconnect message trigger requires 9 polls AKA 9 seconds)
        if (self.beaconDisconnectInteger > 8) { //Greater than operator to prevent accidental overshoot of integer
            // No beacons are in range
            _signalIndicator.image = [self applySignal:0];
            _inferredLocation.text = @"No Signal";
            _inferredInfo.text = @"The app detected no or weak Bluetooth signals from the iBeacons. You might not be in the beacon coverage zone. Please walk around SST  to double check your connection.";
            if (![self.lastUsedImage isEqualToString:@"SSTGeneric"]) {
                [self setBackgroundImage:@"SSTGeneric"];
                self.lastUsedImage = @"SSTGeneric";
            }
        } else {
            self.beaconDisconnectInteger++;
        }
        
        if (debugMode) {
            NSLog(@"No beacons were detected");
            _beaconDisconnectThreshold.text = [NSString stringWithFormat:@"%hd/9", self.beaconDisconnectInteger];
            _rawConnectivity.text = @"DISCONNECTED";
            _rawRSSI.text = @"RSSI: -dBm";
        }
    }
}

#pragma mark -

-(UIImage *)applySignal:(short)imageId {
    // Image ID is as below:
    // 0 is none
    // 1 is low
    // 2 is half
    // 3 is full
    
    if (iPadIsUsed) {
        switch (imageId) {
            case 0:
                return [PlacesKit imageOfNone_iPad];
                break;
                
            case 1:
                return [PlacesKit imageOfLow_iPad];
                break;
                
            case 2:
                return [PlacesKit imageOfHalf_iPad];
                break;
                
            case 3:
                return [PlacesKit imageOfFull_iPad];
                
            default:
                return [PlacesKit imageOfNone_iPad];
                break;
        }
    } else {
        switch (imageId) {
            case 0:
                return [PlacesKit imageOfNone];
                break;
                
            case 1:
                return [PlacesKit imageOfLow];
                break;
                
            case 2:
                return [PlacesKit imageOfHalf];
                break;
                
            case 3:
                return [PlacesKit imageOfFull];
                
            default:
                return [PlacesKit imageOfNone];
                break;
        }
    }
}

-(void)setBackgroundImage:(NSString *)imageName {
    [UIView transitionWithView:_bgImg duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{_bgImg.image = [UIImage imageNamed:imageName];} completion:nil];
}

// This will set the text and images accordingly
// The URLs are also set inside this method
-(void)setTextInfoWithMajor:(NSString *)major minor:(NSString *)minor
{
    locationString = [[NSString alloc] init];
    
    // Admin block
    if ([major isEqual:@"1"]) {
        if ([minor isEqual:@"1"]) {
            if (![self.lastUsedImage isEqualToString:@"SSTWallDefault"]){
                [self setBackgroundImage:@"SSTWallDefault"];
                self.lastUsedImage = @"SSTWallDefault";
            }
            locationString = [locationString stringByAppendingString:@"SST Wall"];
            _inferredInfo.text = @"This is the SST Wall, Visitors to SST, from both Singapore and overseas take their group shots here.\n\nTap on the iBeacon to visit the SST website and learn more about SST.";
            linkURL = @"http://www.sst.edu.sg";
        }
        else
            //locationString=@"Weak Signal";
            goto unimplemented;
    }
    // Block B
    else if ([major isEqual:@"2"]) {
        if ([minor isEqual:@"2"]){
            locationString = [locationString stringByAppendingString:@"Exhibition Centre"];
            if (![self.lastUsedImage isEqualToString:@"ExhibitionStudioDefault"]) {
                [self setBackgroundImage:@"ExhibitionStudioDefault"];
                self.lastUsedImage = @"ExhibitionStudioDefault";
            }
            _inferredInfo.text = @"The Exhibition Center is a place for students and the school to showcase their works and achievements, ranging from art pieces to outstanding ISS (Interdisciplinary Science Studies) projects. This place houses the school's various achievements.\n\nYou can view the SST Corporate Video by tapping your phone on the iBeacon.";
            linkURL = @"http://www.sst.edu.sg/media-centre/sst-corporate-video";
        }
        else {
            goto unimplemented;
        }
    }
    // Block C
    else if ([major isEqual:@"3"]) {
        if ([minor isEqual:@"1"]) {
            if (![self.lastUsedImage isEqualToString:@"ScienceHubDefault"]) {
                [self setBackgroundImage:@"ScienceHubDefault"];
                self.lastUsedImage = @"ScienceHubDefault";
            }
            locationString = [locationString stringByAppendingString:@"Science Hub"];
            _inferredInfo.text = @"Opportunities for independent and joint research experimentation abound in our state-of-the-art Science Hub, which comprises twelve laboratories (four dedicated to the Applied Sciences), as well as a tissue culture room, a research lab and an engineering lab.\n\nThe unique multifunctional NAWIS® system in the Physics laboratories allows for more flexibility and mobility in these spaces. Special research equipment are also available in the laboratories to support students’ explorations in the fields of Analytical Chemistry, Biomedical Sciences and Sensor Technology.";
            linkURL = @"";
        }
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"SST Inc"];
            if (![self.lastUsedImage isEqualToString:@"MakerspaceDefault"]) {
                [self setBackgroundImage:@"MakerspaceDefault"];
                self.lastUsedImage = @"MakerspaceDefault";
            }
            _inferredInfo.text = @"The SST Makerspace is a fully-equipped learning zone where students can design, prototype and manufacture products. Makerspaces are a fairly new phenomenon, but are beginning to make waves in the field of education. The SST Makerspace represents the democratisation of design, engineering, fabrication and education, and empowers our students with the resources to unleash their creativity.\n\nThe Makerspace includes the SST Inc room, a room dedicated to makers and tinkerers who want to develop softwares that empower SST and the world, including this app that you are using right now, Places@SST. The background of this screen is the Ideation Tunnel, a place where members of SST Inc discuss their ideas and sketch them out on the glass whiteboards.\n\nTap on the beacon to access the SST Inc website.";
            linkURL = @"http://sstinc.org";
        }
        else if ([minor isEqual:@"3"]) {
            locationString = [locationString stringByAppendingString:@"Beta Labs"];
            if (![self.lastUsedImage isEqualToString:@"BetaLabsDefault"]) {
                [self setBackgroundImage:@"BetaLabsDefault"];
                self.lastUsedImage = @"BetaLabsDefault";
            }
            _inferredInfo.text = @"The Beta Lab is a new generation classroom concept of what a future classroom should be like. Currently adopted in tertiary institutes in Singapore, the room facilitates collaboration and small group discussions due to the integration of technology within its layout.";
            linkURL = @"";
        }
        else if ([minor isEqual:@"4"]) {
            locationString = [locationString stringByAppendingString:@"Robotics Room"];
            /*if (![self.lastUsedImage isEqualToString:@"RoboticsDefault"]) {
                [self setBackgroundImage:@"RoboticsDefault"];
                self.lastUsedImage = @"RoboticsDefault";
             }*/
            _inferredInfo.text = @"";
            linkURL = @"";
        }
        else {
            //locationString=@"Polling...";
            goto unimplemented;
        }
    }
    // Sports complex
    else if ([major isEqual:@"4"]) {
        locationString = [locationString stringByAppendingString:@"Sports Complex"];
        if (![self.lastUsedImage isEqualToString:@"SportsComplexDefault"]) {
            [self setBackgroundImage:@"SportsComplexDefault"];
            self.lastUsedImage = @"SportsComplexDefault";
        }
        _inferredInfo.text = @"The Ngee Ann Kongsi Sports Complex consists of a multi-purpose hall, an indoor sports hall, gym, dance studio, music room and a rooftop basketball court cum running track. Outdoor sports facilities include a synthetic football field and a NAPFA fitness area, in addition to three CCA rooms and a student leader lounge.";
        linkURL = @"http://www.sst.edu.sg/curriculum/sports-and-wellness/";
    }
    else
    {
    unimplemented:
        locationString = @"Not Implemented";
        if (![self.lastUsedImage isEqualToString:@"SSTGeneric"]) {
            [self setBackgroundImage:@"SSTGeneric"];
            self.lastUsedImage = @"SSTGeneric";
        }
        _inferredInfo.text = @"This location seems to be a new beacon in deployment or configuration, but we haven't finished it yet! Look out for new locations in the next release of Places@SST!";
        linkURL = @"http://sstinc.org";
    }
    
    // Finally set the text
    _inferredLocation.text = locationString;
}

#pragma mark - CBCentralManager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if ([central state] == CBCentralManagerStatePoweredOn) {
        //bluetoothEnabled = YES
        //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    else {
        //bluetoothEnabled = NO;
        //[self.tabBarController performSegueWithIdentifier:@"NoBluetoothSegue" sender:self.tabBarController];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"NoBluetoothSegue" sender:self];
        });
    }
}

- (void)startBluetoothStatusMonitoring {
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqual:@"ShowDetail"]) {
        // If the segue is going to the In App Browser
        InAppBrowserViewController *vc = (InAppBrowserViewController *)[[segue destinationViewController] topViewController];
        [vc setUrlString:[NSURL URLWithString:linkURL]];
    }
}

@end
