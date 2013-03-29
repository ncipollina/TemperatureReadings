//
//  CTCDetailViewController.m
//  TemperatureReadings
//
//  Created by Nicholas Cipollina on 03/25/13.
//  Copyright (c) 2013 CapTech Consulting, Inc. All rights reserved.
//

#import "CTCDetailViewController.h"
#import "CTCReading.h"

@interface CTCDetailViewController ()
- (void)configureView;
@end

@implementation CTCDetailViewController

#pragma mark - Managing the detail item

- (void)setReading:(CTCReading *)reading{
    if (_reading != reading) {
        _reading = reading;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.reading) {
        self.temperatureText.text = [NSString stringWithFormat:@"%i", self.reading.temperature];
        self.stepper.value = self.reading.temperature;
        self.dateTaken.date = self.reading.readingDate;
        self.verified.on = self.reading.temperatureValidated;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stepperChanged:(id)sender {
    NSNumber *number = [NSNumber numberWithDouble:self.stepper.value];
    self.temperatureText.text = [NSString stringWithFormat:@"%i", [number integerValue]];
}

- (IBAction)saveClicked:(id)sender {
    self.reading.readingDate = self.dateTaken.date;
    self.reading.temperature = (NSInteger) self.stepper.value;
    self.reading.temperatureValidated = self.verified.on;
    [self.delegate detailView:self didSaveReading:self.reading];
}

- (IBAction)cancelClicked:(id)sender {
    [self.delegate detailViewDidCancel:self];
}
@end