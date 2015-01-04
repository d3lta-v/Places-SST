//
//  EventsTableViewController.h
//  Places@SST
//
//  Created by Pan Ziyue on 24/12/14.
//  Copyright (c) 2014 StatiX Industries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsTableViewController : UITableViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>

-(void)refresh:(id)sender;

@end
