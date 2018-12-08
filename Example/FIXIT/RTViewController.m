//
//  RTViewController.m
//  FIXIT
//
//  Created by rickytan on 12/08/2018.
//  Copyright (c) 2018 rickytan. All rights reserved.
//

#import <FIXIT/FIXIT.h>

#import "RTViewController.h"

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Text VC";

    // Do any additional setup after loading the view, typically from a nib.
//    [[FIXIT fix] executeScript:@"var fix = new FIXIT('RTViewController');\nvar origin = fix.fixInstanceMethod('_crash:', function(self) {\n    console.log(self);\n    console.log(arguments);\n    return \"success\";\n});\n\nconsole.log(origin);"];
    [[FIXIT fix] executeScript:@"var fix = Fixit.fix('RTViewController');\nvar origin = fix.instanceMethod('locationOf:atIndex:defaultValue:', function(self, locations, index, point) {\n    console.log(self.title(), point.CGPointValue());\n    if (index > locations.length) {\n        return locations[locations.length - 1].CGPointValue();\n    }\n    return locations[index];\n});"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id p = [self locationOf:@[[NSValue valueWithCGPoint:CGPointMake(-0.33, 0.89)]] atIndex:2 defaultValue:CGPointMake(0.5, 1.25)];
        NSLog(@"%@", p);
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)_crash:(NSString *)lastName a:(id)obja b:(id)objb c:(id)objc
{
    ((char *)NULL)[2] = 'c';
    return [NSString stringWithFormat:@"fail: %@", lastName];
}

- (id)locationOf:(NSArray <NSValue *> *)locations atIndex:(NSInteger)index defaultValue:(CGPoint)point
{
    return locations[index];
}

@end
