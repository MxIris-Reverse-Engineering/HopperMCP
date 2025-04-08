//
//  HPSwiftFieldDesc.h
//  Hopper
//
//  Created by JH on 2025/4/8.
//

#import <Foundation/Foundation.h>

@protocol HPSwiftFieldDesc <NSObject>

@property (nonatomic) BOOL isDirect;
@property (nonatomic) BOOL isVar;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *name;

- (instancetype)initWithType:(NSString *)type name:(NSString *)name andFlags:(unsigned int)flags;

@end
