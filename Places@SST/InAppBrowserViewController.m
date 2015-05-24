//
//  InAppBrowserViewController.m
//  Places@SST
//
//  Created by Pan Ziyue on 4/1/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import "InAppBrowserViewController.h"
#import "NJKWebViewProgressView.h"
#import "SVProgressHUD.h"
#import "TUSafariActivity.h"

@interface InAppBrowserViewController ()
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    bool stopBool; //stop means true, refresh means false
}

@end

@implementation InAppBrowserViewController

@synthesize urlString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize NJKWebViewProgress
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _mainWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    
    // Start loading
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:self.urlString]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [self setToolbarItems:@[_fixedSpace1iPad, _backButton, _fixedSpace2iPad, _forwardButton, _flexSpace3iPad, _refreshButton, _fixedSpace4iPad, _exportButton, _fixedSpace5iPad]];
    } else {
        [self setToolbarItems:[NSArray arrayWithObjects:_flexSpace1,_backButton,_fixedSpace2,_forwardButton,_fixedSpace3,_refreshButton,_fixedSpace4,_exportButton,_flexSpace5, nil] animated:NO];
    }
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(IBAction)exitNavigationVC:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)goBack:(id)sender {
    [_mainWebView goBack];
}

- (IBAction)goForward:(id)sender {
    [_mainWebView goForward];
}

- (IBAction)exportAction:(id)sender {
    if (_mainWebView.request.mainDocumentURL!=nil) {
        TUSafariActivity *activity = [[TUSafariActivity alloc] init];
        UIActivityViewController *actViewCtrl=[[UIActivityViewController alloc]initWithActivityItems:@[_mainWebView.request.mainDocumentURL] applicationActivities:@[activity]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:actViewCtrl animated:YES completion:nil];
        }
        else {
            // Change Rect to position Popover
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:actViewCtrl];
            [popup presentPopoverFromRect:[[self.exportButton valueForKey:@"frame"] frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    } else {
        return;
    }
}

- (IBAction)refreshOrStop:(id)sender {
    if (stopBool) {
        [_mainWebView stopLoading];
    } else {
        [_mainWebView reload];
    }
}

#pragma mark - UIWebViewDelegate and related
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code!=-999) {
        [SVProgressHUD showErrorWithStatus:@"Loading failed, check your Internet connection"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

-(void)refreshAction
{
    [_mainWebView reload];
}

-(void)stopAction
{
    [_mainWebView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    
    if (progress<1.0f) {
        UIBarButtonItem *bttn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
        _refreshButton = bttn;
        stopBool = true;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else if (progress==1.0f) { // finished loading
        UIBarButtonItem *bttn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
        _refreshButton = bttn;
        stopBool = false;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    self.navigationItem.title = [_mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [_backButton setEnabled:[_mainWebView canGoBack]];
    [_forwardButton setEnabled:[_mainWebView canGoForward]];
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

@end
