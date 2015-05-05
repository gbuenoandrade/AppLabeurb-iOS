//
//  ViewController.m
//  ChatClient
//
//  Created by Guilherme Andrade on 5/5/15.
//  Copyright (c) 2015 Unicamp. All rights reserved.
//

#import "ViewController.h"

#define SERVER_PORT 7856

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *joinView;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (strong, nonatomic) NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (NSMutableArray*)messages {
	if (!_messages) {
		_messages = [NSMutableArray array];
	}
	return _messages;
}

- (IBAction)joinChat:(id)sender {
	NSString *response = [NSString stringWithFormat:@"iam:%@", self.inputNameField.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
	[self.view bringSubviewToFront:self.chatView];
}

- (void)initNetworkCommunication {
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", SERVER_PORT, &readStream, &writeStream);
	self.inputStream = (__bridge NSInputStream*)readStream;
	self.outputStream = (__bridge NSOutputStream*)writeStream;
	[self.inputStream setDelegate:self];
	[self.outputStream setDelegate:self];
	[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.inputStream open];
	[self.outputStream open];
}

- (IBAction)sendMessage:(id)sender {
	NSString *response = [NSString stringWithFormat:@"msg:%@", self.inputMessageField.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initNetworkCommunication];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"ChatCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	NSString *s = (NSString*)[self.messages objectAtIndex:indexPath.row];
	cell.textLabel.text = s;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.messages.count;
}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	switch (eventCode) {
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
			if(aStream == self.inputStream) {
				uint8_t buffer[1024];
				int len;
				while([self.inputStream hasBytesAvailable]) {
					len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
					if(len>0) {
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						if(nil!=output) {
							[self messageReceived:output];
						}
					}
				}
			}
			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
			break;
		default:
			NSLog(@"Unknown event");
	}
}

- (void)messageReceived:(NSString*)message {
	[self.messages addObject:message];
	[self.tableView reloadData];
}

@end
