//
//  CTCMasterViewController.m
//  TemperatureReadings
//
//  Created by Nicholas Cipollina on 03/25/13.
//  Copyright (c) 2013 CapTech Consulting, Inc. All rights reserved.
//

#import "CTCMasterViewController.h"

#import "CTCDetailViewController.h"
#import "CTCReadingsService.h"
#import "CTCReading.h"

@interface CTCMasterViewController () {
}
@end

@implementation CTCMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;


    // This logic could be used to show an activity indicator in the app
    [CTCReadingsService sharedService].busyUpdate = ^(BOOL busy){
        if (busy){
            NSLog(@"Service is busy");
        } else {
            NSLog(@"Service is not busy");
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![CTCReadingsService sharedService].client.currentUser){
        [self performSelector:@selector(login) withObject:self afterDelay:0.1];
    }
}

- (void)login{
    UIViewController *controller = [[CTCReadingsService sharedService].client
            loginViewControllerWithProvider:@"google"
                                 completion:^(MSUser *user, NSError *error){
                                     if (error){
                                         NSLog(@"Authentication Error: %@", error);
                                     } else {
                                         [[CTCReadingsService sharedService] refreshDataOnSuccess:^{
                                             [self.tableView reloadData];
                                         }];
                                     }

                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];

    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CTCReadingsService sharedService].readings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    CTCReading *reading = [CTCReadingsService sharedService].readings[(NSUInteger) indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%i at %@", reading.temperature, [reading.readingDate description]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        CTCReading *reading = [CTCReadingsService sharedService].readings[(NSUInteger)indexPath.row];
        [[CTCReadingsService sharedService] deleteReading:reading
                                               completion:^(NSUInteger index){
                                                   [self.tableView beginUpdates];
                                                   [self.tableView
                                                           deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                                   [self.tableView endUpdates];
                                               }];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    CTCDetailViewController *detailViewController = [[navigationController viewControllers] objectAtIndex:0];
    detailViewController.delegate = self;
    CTCReading *reading;
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        reading = [CTCReadingsService sharedService].readings[indexPath.row];
    } else if ([[segue identifier] isEqualToString:@"addReading"]){
        reading = [CTCReading new];
    }
    detailViewController.reading = reading;
}

#pragma mark - CTCDetailViewControllerDelegate

- (void)detailViewDidCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)detailView:(id)sender didSaveReading:(CTCReading *)reading {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (reading.identifier == 0) {
        [[CTCReadingsService sharedService] addReading:reading completion:^(NSUInteger index){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
    } else {
        [[CTCReadingsService sharedService] updateReading:reading completion:^(NSUInteger index){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
    }
}


@end