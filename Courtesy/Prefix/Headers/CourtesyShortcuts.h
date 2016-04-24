//
//  CourtesyShortcuts.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyShortcuts_h
#define CourtesyShortcuts_h

#define tryValue(property, value) (property = property ? property : value)
#define sharedSettings ([GlobalSettings sharedInstance])
#define kLogin [sharedSettings hasLogin]
#define kAccount [sharedSettings currentAccount]
#define kProfile [kAccount profile]

#endif /* CourtesyShortcuts_h */
