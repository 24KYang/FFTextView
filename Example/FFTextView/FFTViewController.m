//
//  FFTViewController.m
//  FFTextView
//
//  Created by 徐洋 on 07/08/2024.
//  Copyright (c) 2024 徐洋. All rights reserved.
//

#import "FFTViewController.h"
#import <FFTextView/FFTextView.h>

#import <Masonry/Masonry.h>

@interface FFTViewController ()

@end

@implementation FFTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    FFTextConfig *config = [[FFTextConfig alloc] init];
    config.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];
    config.textColor = UIColor.redColor;
    config.font = [UIFont systemFontOfSize:14];
    config.height = 40;
    
    FFTextView *textView = [[FFTextView alloc] initWithPlaceholder:@"这是一段占位符, 还可以换行, 来凑够一行的文字(test-test-test-test)" config:config];
    textView.backgroundColor = UIColor.lightGrayColor;
    
    FFTextFormatter *formatter = [[FFTextFormatter alloc] init];
    formatter.configStyle = FFTextFormatterCustomStyle;
    formatter.configFormat = @"C######T";
    
    textView.formatter = formatter;
    textView.maxLength = 100;
    textView.includeLineBreak = YES;

    [self.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.size.mas_equalTo(CGSizeMake(300, 300));
        make.top.offset(100);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
