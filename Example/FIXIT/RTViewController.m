//
//  RTViewController.m
//  FIXIT
//
//  Created by rickytan on 12/08/2018.
//  Copyright (c) 2018 rickytan. All rights reserved.
//

#import <FIXiT/FIXiT.h>

#import "RTViewController.h"

#define JSString(code)      @#code

@interface NSObject (Crash)
- (void)crashIt;
@end

@implementation NSObject (Crash)

- (void)crashIt
{
    NSLog(@"%@", @[][1]);
}

@end

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Text VC";

    // Do any additional setup after loading the view, typically from a nib.
    NSString *script = [[NSBundle mainBundle] pathForResource:@"patch" ofType:@"js"];
    [[FIXIT fix] executeScript:[NSString stringWithContentsOfFile:script
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            CGPoint p = [self locationOf:@[[NSValue valueWithCGPoint:CGPointMake(-0.33, 1.28)]] atIndex:2 defaultValue:CGPointMake(0.5, 1.5)];
            NSLog(@"%@", NSStringFromCGPoint(p));
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint p = [self locationOf:@[[NSValue valueWithCGPoint:CGPointMake(-0.33, 1.28)]] atIndex:0 defaultValue:CGPointMake(0.5, 1.5)];
            NSLog(@"%@", NSStringFromCGPoint(p));

            [@[@1, @3, @4] crashIt];
            [@[@"abc", @"yes"] crashIt];
            [self crashIt];
        });
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

- (CGPoint)locationOf:(NSArray <NSValue *> *)locations atIndex:(NSInteger)index defaultValue:(CGPoint)point
{
    return locations[index].CGPointValue;
}

@end
