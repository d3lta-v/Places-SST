//
//  AboutViewController.m
//  Places
//
//  Created by Pan Ziyue on 25/5/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import "AboutViewController.h"
#import "InAppBrowserViewController.h"

@interface AboutViewController ()
{
    NSString *urlToPass;
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)siddhantButton:(id)sender {
    urlToPass = @"http://siddhant.me";
    [self performSegueWithIdentifier:@"gotoWebview" sender:self];
}

- (IBAction)ziyueButton:(id)sender {
    urlToPass = @"https://twitter.com/sammy0025";
    [self performSegueWithIdentifier:@"gotoWebview" sender:self];
}

- (IBAction)xtButton:(id)sender {
    urlToPass = @"https://statixind.net/about.html";
    [self performSegueWithIdentifier:@"gotoWebview" sender:self];
}

- (IBAction)christopherButton:(id)sender {
    urlToPass = @"https://statixind.net/about.html";
    [self performSegueWithIdentifier:@"gotoWebview" sender:self];
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"gotoWebview"]) {
        // If the segue is going to the In App Browser
        InAppBrowserViewController *vc = (InAppBrowserViewController *)[[segue destinationViewController] topViewController];
        [vc setUrlString:[NSURL URLWithString:urlToPass]];
    }
}


@end
