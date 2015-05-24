//
//  InAppBrowserViewController.h
//  Places@SST
//
//  Created by Pan Ziyue on 4/1/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NJKWebViewProgress.h"

@interface InAppBrowserViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;

// iPhone Bar Button Items
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace1;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace3;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace4;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace5;

// iPad Bar Button Items
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace1iPad;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace2iPad;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace3iPad;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace4iPad;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace5iPad;

@property (copy, nonatomic) NSURL *urlString;

-(IBAction)exitNavigationVC:(id)sender;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)exportAction:(id)sender;
- (IBAction)refreshOrStop:(id)sender;

@end
