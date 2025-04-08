//
//  HPSwiftProtocolDesc.h
//  Hopper
//
//  Created by JH on 2025/4/8.
//

#import <Foundation/Foundation.h>
#import "CommonTypes.h"

@protocol HPSwiftProtocolDesc <NSObject>

@property (nonatomic) Address descAddress;
@property (copy, nonatomic) NSString *context;
@property (nonatomic) unsigned int flags;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *associatedValue;
@property (copy, nonatomic) NSArray *requirements;


@end
