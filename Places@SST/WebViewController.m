//
//  WebViewController.m
//  Places@SST
//
//  Created by Pan Ziyue on 3/1/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "SIMUXCRParser.h"
#import "TUSafariActivity.h"
#import "NJKWebViewProgressView.h"
#import "InAppBrowserViewController.h"

@interface WebViewController ()
{
    BOOL useWebView;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    NSURL *linkURL;
}

@end

@implementation WebViewController

@synthesize textView, webView;

NSString *url;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    url=self.receivedURL;
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //Here comes the SIMUXCR and the DTHTMLAttributedString!
        SIMUXCRParser *simuxParser = [[SIMUXCRParser alloc]init];
        NSMutableArray *crOptimised = [simuxParser convertHTML:self.receivedURL]; //This will return some HTML which we are gonna parse with DTCoreText
        
        //Get the title and descriptions
        NSString *title = [crOptimised objectAtIndex:0];
        NSString *description = [crOptimised objectAtIndex:1];
        
        if (description==NULL) {
            description = @"<p align=\"center\">There was a problem loading this article, please check your Internet connection, or try opening the URL in Safari via the share button above.</p>";
            title = @"Error";
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            //Replacing some strings
            description = [description stringByReplacingOccurrencesOfString:@"<div><br></div>" withString:@"<div></div>"];
        }
        
        NSData *htmlData=[description dataUsingEncoding:NSUTF8StringEncoding];
        // Custom options for the builder (currently customising font family and font sizes)
        NSDictionary *builderOptions = @{
                                         DTDefaultFontFamily: @"Helvetica Neue",
                                         DTDefaultFontSize: @"16.4px",
                                         DTDefaultLineHeightMultiplier: @"1.43",
                                         DTDefaultLinkColor: @"#146FDF",
                                         DTDefaultLinkDecoration: @""
                                         };
        DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData options:builderOptions documentAttributes:nil];
        self.textView.shouldDrawImages = YES;
        self.textView.attributedString = [stringBuilder generatedAttributedString];
        self.textView.contentInset = UIEdgeInsetsMake(85, 15, 40, 15); //Using insets to make the article look better
        
        // Assign our delegate, this is required to handle link events
        self.textView.textDelegate = self;
        
        self.title=title;
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // Use the UIWebView if it detects iframes, etc. Much better than bouncing to safari
        if ([description rangeOfString:@"Loading..."].location != NSNotFound || [description rangeOfString:@"<iframe"].location != NSNotFound) {
            textView.alpha = 0;
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.receivedURL stringByAppendingString:@"?m=0"]]]];
            [SVProgressHUD showWithStatus:@"Loading Web Version..." maskType:SVProgressHUDMaskTypeBlack];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionSheet:(id)sender
{
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *actViewCtrl=[[UIActivityViewController alloc]initWithActivityItems:@[[[NSURL alloc]initWithString:url]] applicationActivities:@[activity]]; //We need NSURL alloc initwithstring since we are trying to share a URL here. If it's not a URL I don't think TUSafariActivity would work either
    [self presentViewController:actViewCtrl animated:YES completion:nil];
}

#pragma mark - DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    //DTLinkButton is for the links
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    
    linkButton.URL = url;
    [linkButton addTarget:self
                   action:@selector(linkPushed:)
         forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        
        // sets the image if there is one
        imageView.image = [(DTImageTextAttachment *)attachment image];
        
        // url for deferred loading
        imageView.url = attachment.contentURL;
        
        // if there is a hyperlink then add a link button on top of this image
        if (attachment.hyperLinkURL)
        {
            // NOTE: this is a hack, you probably want to use your own image view and touch handling
            // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
            imageView.userInteractionEnabled = YES;
            
            DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
            button.URL = attachment.hyperLinkURL;
            button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
            button.GUID = attachment.hyperLinkGUID;
            
            // use normal push action for opening URL
            [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
            
            [imageView addSubview:button];
        }
        
        return imageView;
    }
    else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
    {
        DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.attachment = attachment;
        
        return videoView;
    }
    else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
    {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

#pragma mark DTLazyImageViewDelegate
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *imageURL = lazyImageView.url;
    CGSize imageSize = size;
    
    CGSize screensize;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        
        if (screenHeight==480) { // 3.5inch
            screensize=CGSizeMake(280, 480);
        } else if (screenHeight==568) { // 4inch
            //screensize=CGSizeMake(280, 1136);
            screensize=CGSizeMake(280, 568);
        } else if (screenHeight==667) { // 4.7inch
            screensize=CGSizeMake(335, 667);
        } else if (screenHeight==736) { // 5.5inch
            screensize=CGSizeMake(374, 736);
        } else { // Fallback
            screensize=CGSizeMake(280, 568);
        }
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        screensize=CGSizeMake(768.0, 1024.0);
    }
    
    screensize=CGSizeMake(280, 1136);
    
    //Autoresize if width of picture is bigger than width of the screen
    if (size.width > screensize.width) {
        float ratio = screensize.width/size.width;
        imageSize.width = size.width * ratio;
        imageSize.height = size.height *ratio;
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", imageURL];
    
    BOOL didUpdate = NO;
    
    // update all attachments that matchin this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        // layout might have changed due to image sizes
        [self.textView relayoutText];
    }
}

#pragma mark - Actions
- (void)linkPushed:(DTLinkButton *)button
{
    NSURL *URL = button.URL;
    
    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
    {
        linkURL = [URL absoluteURL];
        
        [self performSegueWithIdentifier:@"ToBrowser" sender:self];
    }
    else
    {
        if (![URL host] && ![URL path])
        {
            // possibly a local anchor link
            NSString *fragment = [URL fragment];
            
            if (fragment)
            {
                [self.textView scrollToAnchorNamed:fragment animated:NO];
            }
        }
    }
}

#pragma mark - UIWebView Delegate Methods
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Loading failed!"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [_progressView removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:_progressView];
    [_progressView setProgress:0];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if (progress>0.1f) {
        [SVProgressHUD dismiss];
    }
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    InAppBrowserViewController *vc = (InAppBrowserViewController *)[[segue destinationViewController] topViewController];
    [vc setUrlString:linkURL];
}


@end