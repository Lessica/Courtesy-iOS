Objective-C时间戳处理
=====================

Author : CashLee

Date : 2014/02/02

Description : 在处理Timeline的时候往往需要将时间戳转换成过往时间，该库简单地处理了该问题。


How To Install
--------------

    pod 'oc-timestamp', :git => 'https://github.com/lbj96347/oc-timestamp.git'


How To Use
---------

  添加文件

    import 'Timestamp.h'

  使用方法：

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:@"2014-01-08T11:33:03Z"];

    Timestamp *timeStamp = [[Timestamp alloc]init];
    NSString *timeStr = [[NSString alloc]initWithFormat:@"%@",[timeStamp compareCurrentTime:date]];

    NSLog(@"%@", timeStr );//输出结果
