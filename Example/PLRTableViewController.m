//
//  PLRTableViewController.m
//  PaylerSDK
//
//  Created by Максим Павлов on 16.07.14.
//  Copyright (c) 2014 Polonium Arts. All rights reserved.
//

#import "PLRTableViewController.h"
#import "PLRViewController.h"

static NSString *const OneStepSegueIdentifier = @"OneStepSegue";
static NSString *const TwoStepSegueIdentifier = @"TwoStepSegue";

@implementation PLRTableViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PLRViewController *controller = segue.destinationViewController;
    if ([segue.identifier isEqualToString:OneStepSegueIdentifier]) {
        controller.sessionType = PLRSessionTypeOneStep;
    } else if ([segue.identifier isEqualToString:TwoStepSegueIdentifier]) {
        controller.sessionType = PLRSessionTypeTwoStep;
    }
}

@end
