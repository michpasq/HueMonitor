//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
#import "MMHueRequest.h"
#import "MMWatchPixelController.h"
@import AppKit;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *numberOfHotspots;
@property (strong, atomic) MMWatchPixelController *hotspotController;
@property (strong, atomic) id hotspotSelectionMonitor;
@property (strong, atomic) NSMutableArray *validLights;
@property (weak) IBOutlet NSTextField *lightsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfHotspots.stringValue = @"3";
    self.hotspotController = [[MMWatchPixelController alloc] init];
    
    self.validLights = [[NSMutableArray alloc] init];
    [MMHueRequest getNumberOfLights:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *lights = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [lights enumerateKeysAndObjectsUsingBlock:^(NSString *lightID, NSDictionary *light, BOOL *stop) {
            if([light[@"state"][@"reachable"] boolValue])
            {
                [self.validLights addObject:[NSNumber numberWithInteger:lightID.integerValue ]];
                self.lightsLabel.stringValue = [NSString stringWithFormat:@"%lu lights found", self.validLights.count];
            }
        }];
    }];

    // Do any additional setup after loading the view.
}
- (IBAction)setHotspots:(id)sender {
    if(self.numberOfHotspots.stringValue.integerValue == 0)
    {
        // Not a valid number of hotspots maybe?
        return;
    }
    self.numberOfHotspots.editable = NO;
    [self.hotspotController emptyPixelArray];
    // Hide window for hotspot selection
    [self.view.window orderOut:nil];
    
    self.hotspotSelectionMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        NSLog(@"%f,%f",event.locationInWindow.x,event.locationInWindow.y);
        [self.hotspotController addPixelAtEvent:event];
        if([self.hotspotController pixelCount] == self.numberOfHotspots.stringValue.integerValue)
        {
            [NSEvent removeMonitor:self.hotspotSelectionMonitor];
            [self.view.window orderFrontRegardless];
            self.numberOfHotspots.editable = YES;
        }
    }];
}
- (IBAction)toggleMonitoring:(NSButton *)sender {
    if([sender.title isEqualToString:@"Start Monitoring"])
    {
        sender.title = @"Stop Monitoring";
        [self.hotspotController startMonitoring];
    }
    else
    {
        sender.title = @"Start Monitoring";
        [self.hotspotController stopMonitoring];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
