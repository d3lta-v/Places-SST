//
//  WebViewController.h
//  Places@SST
//
//  Created by Pan Ziyue on 3/1/15.
//  Copyright (c) 2015 StatiX Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCoreText.h"
#import "NJKWebViewProgress.h"

@interface WebViewController : UIViewController <UIGestureRecognizerDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    IBOutlet DTAttributedTextView *textView;
    IBOutlet UIWebView *webView;
}

@property (strong, nonatomic) IBOutlet DTAttributedTextView *textView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *receivedURL;

@end
