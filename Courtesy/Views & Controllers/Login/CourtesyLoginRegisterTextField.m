//
//  CourtesyLoginRegisterTextField.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLoginRegisterTextField.h"

@interface CourtesyLoginRegisterTextField () <UITextFieldDelegate>

@end

@implementation CourtesyLoginRegisterTextField

#define CYPlaceholderColorKey @"placeholderLabel.textColor"
#define CYPlaceholderDefaultColor [UIColor lightGrayColor]
#define CYPlaceholderFocusColor [UIColor whiteColor]

- (void)awakeFromNib {
    self.tintColor = CYPlaceholderFocusColor;
    self.textColor = CYPlaceholderFocusColor;
    [self setValue:CYPlaceholderDefaultColor forKeyPath:CYPlaceholderColorKey];
    [self setDelegate:self];
    [self resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    [self setValue:CYPlaceholderFocusColor forKeyPath:CYPlaceholderColorKey];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [self setValue:CYPlaceholderDefaultColor forKeyPath:CYPlaceholderColorKey];
    return [super resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == [self.superview viewWithTag:1]) {
        [textField resignFirstResponder];
        [[self.superview viewWithTag:2] becomeFirstResponder];
    } else if (textField == [self.superview viewWithTag:3]) {
        [textField resignFirstResponder];
        [[self.superview viewWithTag:4] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

@end
