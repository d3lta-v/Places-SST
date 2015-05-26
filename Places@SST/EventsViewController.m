//
//  EventsViewController.m
//  Places
//
//  Created by Pan Ziyue on 26/5/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import "EventsViewController.h"
#import "PlacesKit.h"

@interface EventsViewController ()

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.calendarIcon.image = [PlacesKit imageOfCalendar_Icon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)subscribeToCal:(id)sender {
    NSString *url = @"webcal://www.google.com/calendar/ical/iem02ijg1c7m7kgo7m6fec6u9s%40group.calendar.google.com/private-94d6cdab2e32b795db7b3831630bf3b3/basic.ics";
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    });
}

@end
