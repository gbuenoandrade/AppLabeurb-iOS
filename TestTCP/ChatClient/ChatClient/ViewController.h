//
//  ViewController.h
//  ChatClient
//
//  Created by Guilherme Andrade on 5/5/15.
//  Copyright (c) 2015 Unicamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputNameField;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageField;

@end

