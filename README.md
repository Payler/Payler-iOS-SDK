# PaylerSDK

A simple wrapper to work with Payler Gate API.

## Example Usage

    PaylerAPIClient *client = [[PaylerAPIClient alloc] initWithMerchantKey:@"..." password:@"..."];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:@"paymentId" amount:10000];
    [client refundPayment:payment completion:^(PLRPayment *payment, NSDictionary *info, NSError *error) {
        if (!error) {
            NSLog(@"Refund completed");
        } else {
            NSLog(@"Error: %@", error);
        }
    }];

Download sample project to see more examples.

## Requirements
PaylerSDK requires iOS 6.0 or later.

## Installation

PaylerSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "PaylerSDK"

## Contact

Maxim Pavlov, <mp@poloniumarts.com>

## License

PaylerSDK is available under the MIT license. See the LICENSE file for more info.

