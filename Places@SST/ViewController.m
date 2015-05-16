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

//static const int kDefaultFontSize = 75.0;

@interface ViewController ()
{
    NSString *locationString;
    NSString *linkURL;
    bool inRegion;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _inferredLocation.adjustsFontSizeToFitWidth = YES;
    inRegion = false;
    _signalIndicator.image = [PlacesKit imageOfNone];
    linkURL = @"";
    
    // Check if bluetooth is on or off
    [self startBluetoothStatusMonitoring];
    
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    //self.locationManager.avoidUnknownStateBeacons = YES;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"775752A9-F236-4619-9562-84AC9DE124C6"];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"Estimote Region"];
    
    //TODO: Remove debug code on deployment
    NSArray *locationServicesAuthStatuses = @[@"Not determined",@"Restricted",@"Denied",@"Authorized"];
    NSArray *backgroundRefreshAuthStatuses = @[@"Restricted",@"Denied",@"Available"];
    
    BOOL monitoringAvailable = [CLLocationManager isMonitoringAvailableForClass:[self.myBeaconRegion class]];
    NSLog(@"Monitoring available: %@", [NSNumber numberWithBool:monitoringAvailable]);
    
    int lsAuth = (int)[CLLocationManager authorizationStatus];
    NSLog(@"Location services authorization status: %@", [locationServicesAuthStatuses objectAtIndex:lsAuth]);
    
    int brAuth = (int)[[UIApplication sharedApplication] backgroundRefreshStatus];
    NSLog(@"Background refresh authorization status: %@", [backgroundRefreshAuthStatuses objectAtIndex:brAuth]);
    
    self.lastUsedImage = @"SSTGeneric";
    
    // Start monitoring
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    //[self.locationManager requestStateForRegion:self.myBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    // Did enter region
    NSLog(@"didEnterRegion Triggered!");
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    // Enter code that states it is out of region now
    NSLog(@"didExitRegion Triggered! Stopping ranging services...");
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    _signalIndicator.image = [PlacesKit imageOfNone];
    if (![self.lastUsedImage isEqualToString:@"SSTGeneric"])
        [self setBackgroundImage:@"SSTGeneric"];
    _inferredLocation.text = @"No Signal";
    _inferredInfo.text = @"The app detected no Bluetooth signals from the iBeacons. You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
}

/*- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside: {
            NSLog(@"Inside region, beginning ranging");
            [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
        }
            break;
        case CLRegionStateOutside: {
            NSLog(@"Outside region");
            // No beacons are in range
            _signalIndicator.image = [PlacesKit imageOfNone];
            _inferredLocation.text = @"No Signal";
            _inferredInfo.text = @"The app detected no Bluetooth signals from the iBeacons. You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
        }
            break;
        case CLRegionStateUnknown:
            NSLog(@"State unknown");
            break;
        default:
            // stop ranging beacons, etc
            NSLog(@"Region unknown");
            //[self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    }
}*/

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count]>0) {
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
        
        switch(foundBeacon.proximity) {
            case CLProximityFar:
                _signalIndicator.image = [PlacesKit imageOfHalf];
                break;
            case CLProximityNear:
                _signalIndicator.image = [PlacesKit imageOfFull];
                break;
            case CLProximityImmediate:
                _signalIndicator.image = [PlacesKit imageOfFull];
                if (![linkURL isEqualToString:@""]) {
                    // Initiate segue only when linkURL is not empty
                    [self performSegueWithIdentifier:@"ShowDetail" sender:self];
                }
                break;
            case CLProximityUnknown:
                return;
        }
        
        // Call the function to automatically set the text
        [self setTextInfoWithMajor:major minor:minor];
    } else {
        // Beacon count is zero
        NSLog(@"No beacons were detected");
        // No beacons are in range
        _signalIndicator.image = [PlacesKit imageOfNone];
        _inferredLocation.text = @"No Signal";
        _inferredInfo.text = @"The app detected no Bluetooth signals from the iBeacons. You might not be in the beacon coverage zone. Please walk around SST to double check your connection.";
        if (![self.lastUsedImage isEqualToString:@"SSTGeneric"])
            [self setBackgroundImage:@"SSTGeneric"];
    }
}

#pragma mark -

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
            if (![self.lastUsedImage isEqualToString:@"SSTWallDefault"])
                [self setBackgroundImage:@"SSTWallDefault"];
            locationString = [locationString stringByAppendingString:@"SST Wall"];
            _inferredInfo.text = @"This is the SST Wall, the most iconic place in the whole of SST. Visitors to SST, from both Singapore and overseas take their group shots where.\n\nTap on the iBeacon to visit the SST website and learn more about SST.";
            linkURL = @"http://www.sst.edu.sg";
        }
        /*else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"Integrated "];
            [UIView transitionWithView:_bgImg duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{_bgImg.image = [UIImage imageNamed:@"AtriumDefault"];} completion:nil];
            linkURL = @"";
        }*/
        else
            //locationString=@"Weak Signal";
            goto unimplemented;
    }
    // Block B
    else if ([major isEqual:@"2"]) {
        /*if ([minor isEqual:@"1"]) {
            locationString = [locationString stringByAppendingString:@"Visitor Centre"];
            linkURL = @"";
        }*/
        if ([minor isEqual:@"2"]){
            locationString = [locationString stringByAppendingString:@"Exhibition Centre"];
            if (![self.lastUsedImage isEqualToString:@"ExhibitionStudioDefault"])
                [self setBackgroundImage:@"ExhibitionStudioDefault"];
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
            if (![self.lastUsedImage isEqualToString:@"ScienceHubDefault"])
                [self setBackgroundImage:@"ScienceHubDefault"];
            locationString = [locationString stringByAppendingString:@"Science Hub"];
            _inferredInfo.text = @"Opportunities for independent and joint research experimentation abound in our state-of-the-art Science Hub, which comprises twelve laboratories (four dedicated to the Applied Sciences), as well as a tissue culture room, a research lab and an engineering lab.\n\nThe unique multifunctional NAWIS® system in the Physics laboratories allows for more flexibility and mobility in these spaces. Special research equipment are also available in the laboratories to support students’ explorations in the fields of Analytical Chemistry, Biomedical Sciences and Sensor Technology.";
            linkURL = @"";
        }
        else if ([minor isEqual:@"2"]) {
            locationString = [locationString stringByAppendingString:@"SST Inc"];
            if (![self.lastUsedImage isEqualToString:@"MakerspaceDefault"])
                [self setBackgroundImage:@"MakerspaceDefault"];
            _inferredInfo.text = @"The SST Makerspace is a fully-equipped learning zone where students can design, prototype and manufacture products. Makerspaces are a fairly new phenomenon, but are beginning to make waves in the field of education. The SST Makerspace represents the democratisation of design, engineering, fabrication and education, and empowers our students with the resources to unleash their creativity.\n\nThe Makerspace includes the SST Inc room, a room dedicated to makers and tinkerers who want to develop softwares that empower SST and the world, including this app that you are using right now, Places@SST. The background of this screen is the Ideation Tunnel, a place where members of SST Inc discuss their ideas and sketch them out on the glass whiteboards.";
            linkURL = @"";
        }
        else if ([minor isEqual:@"3"]) {
            locationString = [locationString stringByAppendingString:@"Beta Labs"];
            _inferredInfo.text = @"The Beta Lab is a new generation classroom concept of what a future classroom should be like. Currently adopted in tertiary institutes in Singapore, the room facilitates collaboration and small group discussions due to the integration of technology within its layout.";
            linkURL = @"";
        }
        else if ([minor isEqual:@"4"]) {
            locationString = [locationString stringByAppendingString:@"Robotics Room"];
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
        if (![self.lastUsedImage isEqualToString:@"SportsComplexDefault"])
            [self setBackgroundImage:@"SportsComplexDefault"];
        _inferredInfo.text = @"The Ngee Ann Kongsi Sports Complex consists of a multi-purpose hall, an indoor sports hall, gym, dance studio, music room and a rooftop basketball court cum running track. Outdoor sports facilities include a synthetic football field and a NAPFA fitness area, in addition to three CCA rooms and a student leader lounge.";
        linkURL = @"http://www.sst.edu.sg/curriculum/sports-and-wellness/";
    }
    else
    {
    unimplemented:
        locationString = @"Not Implemented";
        if (![self.lastUsedImage isEqualToString:@"SSTGeneric"])
            [self setBackgroundImage:@"SSTGeneric"];
        _inferredInfo.text = @"This location seems to be a new beacon in deployment or configuration, but we haven't finished it yet! Look out for new locations in the next release of Places@SST!";
        linkURL = @"";
        NSLog(@"Not implemented beacon with major,minor: %@, %@", major, minor);
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
