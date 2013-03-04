//
//  IRItemsViewController.m
//  iRemember
//
//  Created by Danis Tazetdinov on 04.03.13.
//  Copyright (c) 2013 Demo. All rights reserved.
//

#import "IRItemsViewController.h"
#import "IRRemainderManager.h"

@interface IRItemsViewController ()

@property (nonatomic, strong) NSArray *remainders;
@property (nonatomic, strong) IRRemainderManager *remainderManager;

-(IBAction)refresh;
-(void)resignActive:(NSNotification*)notification;
-(void)accessGranted:(NSNotification*)notification;

@end

@implementation IRItemsViewController

-(void)resignActive:(NSNotification*)notification
{
#warning TODO: disable UI
    // disable UI
}

-(void)accessGranted:(NSNotification*)notification
{
#warning TODO: enable UI
    if (!self.calendarIdentifier)
    {
        self.calendarIdentifier = [[[self.remainderManager remainderCalendars] lastObject] calendarIdentifier];
    }
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.remainderManager = [[IRRemainderManager alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessGranted:)
                                                 name:IRRemainderManagerAccessGrantedNotification
                                               object:self.remainderManager];
    [self.remainderManager requestAccess];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [self.remainderManager fetchRemaindersInCalendarWithIdentifier:self.calendarIdentifier
                                                        completion:^(NSArray *remainders) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remainders = remainders;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.remainders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RemainderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EKReminder *remainder = self.remainders[indexPath.row];
    
    cell.textLabel.text = remainder.title;
    
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end