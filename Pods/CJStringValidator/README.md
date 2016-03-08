#NSString+CJStringValidator

NSString category to help the validate formate string.

##Example usage

Is e-mail:

	NSString *mail = @"jeremy@opsone.net";
	NSLog(@"%i", [title isEmail]); // return YES

Is phone number:

	NSString *phone = @"0102030405";
	NSLog(@"%i", [phone isPhoneNumber]); // return YES

Is digit:

	NSLog(@"%i", [@"12" isNumeric]); // return YES
	NSLog(@"%i", [@"12.2" isNumeric]); // return NO
	NSLog(@"%i", [@"12,2" isNumeric]); // return NO
	NSLog(@"%i", [@"abc" isNumeric]); // return NO

Is numeric:

	NSLog(@"%i", [@"12" isNumeric]); // return YES
	NSLog(@"%i", [@"12.2" isNumeric]); // return YES
	NSLog(@"%i", [@"12,2" isNumeric]); // return YES
	NSLog(@"%i", [@"abc" isNumeric]); // return NO

Is url:

	NSString *url = @"http://apple.com";
	NSLog(@"%i", [url isUrl]); // return YES

Is min length:

	NSString *string = @"My title";
	NSLog(@"%i", [string isMinLength:2]); // return YES

Is max length:

	NSString *string = @"My title";
	NSLog(@"%i", [string isMaxLength:8]); // return YES

Is min length and max length:

	NSString *string = @"My title";
	NSLog(@"%i", [string isMinLength:2 andMaxLength:4]); // return NO

Is empty:

	NSString *user = @"Jeremy Chaufourier";
	NSLog(@"%i", [user isEmpty]); // return NO


### Creators
[Jérémy Chaufourier](http://github.com/batosai)
[@chaufourier](https://twitter.com/chaufourier)