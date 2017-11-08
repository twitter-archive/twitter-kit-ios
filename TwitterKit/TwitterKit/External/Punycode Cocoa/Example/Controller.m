//
//  Controller.m
//  Punycode
//
//  Created by Wevah on Wed Feb 02 2005.
//  Copyright (c) 2005 Derailer. All rights reserved.
//

#import "Controller.h"
#import "NSStringPunycodeAdditions.h"

@interface Controller ()

@property (weak) IBOutlet NSTextField *normalField;
@property (weak) IBOutlet NSTextField *idnField;

@end

@implementation Controller

- (IBAction)stringToIDNA:(id)sender
{
    self.idnField.stringValue = [sender stringValue].encodedURLString;
}

- (IBAction)stringFromIDNA:(id)sender
{
    self.normalField.stringValue = [sender stringValue].decodedURLString;
}

@end
