//
//  CTCDetailViewController.h
//  TemperatureReadings
//
//  Created by Nicholas Cipollina on 03/25/13.
//  Copyright (c) 2013 CapTech Consulting, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTCReading;

@protocol CTCDetailViewControllerDelegate <NSObject>

-(void)detailViewDidCancel:(id)sender;
-(void)detailView:(id)sender didSaveReading:(CTCReading *)reading;

@end

@interface CTCDetailViewController : UIViewController

@property (strong, nonatomic) CTCReading *reading;
@property (strong, nonatomic) IBOutlet UITextField *temperatureText;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateTaken;
@property (strong, nonatomic) IBOutlet UISwitch *verified;
- (IBAction)stepperChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (nonatomic, weak) id<CTCDetailViewControllerDelegate> delegate;

- (IBAction)saveClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@end

