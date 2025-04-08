//
//  HPSwiftTypeDesc.h
//  Hopper
//
//  Created by JH on 2025/4/8.
//

#import <Foundation/Foundation.h>
#import "CommonTypes.h"

@protocol HPSwiftStructDesc;
@protocol HPSwiftEnumDesc;
@protocol HPSwiftClassDesc;
@protocol HPSwiftFieldDesc;

@protocol HPSwiftTypeDesc <NSObject>

@property (nonatomic) Address descAddress;
@property (nonatomic) unsigned int flags;
@property (copy, nonatomic) NSString *context;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) Address fieldDescriptorAddress;
@property (nonatomic) unsigned long long metaDataAccessFunctionPointer;
@property (nonatomic) int genericArgumentCount;
@property (readonly) id<HPSwiftClassDesc> classDesc;
@property (readonly) id<HPSwiftStructDesc> structDesc;
@property (readonly) id<HPSwiftEnumDesc> enumDesc;

- (NSArray<id<HPSwiftFieldDesc>> *)fields;
- (void)addField:(id<HPSwiftFieldDesc>)field;
- (unsigned long long)typeKind;
- (BOOL)isUnique;
- (BOOL)isGeneric;
- (unsigned char)version;
- (unsigned short)kindSpecificFlags;
- (NSString *)parentContextPrefix;

@end

@protocol HPSwiftTypeSpecificDesc <NSObject>

- (id<HPSwiftTypeDesc>)context;
- (instancetype)initWithContext:(id<HPSwiftTypeDesc>)context;

@end

@protocol HPSwiftEnumDesc <HPSwiftTypeSpecificDesc>
@end

@protocol HPSwiftStructDesc <HPSwiftTypeSpecificDesc>
@end

@protocol HPSwiftClassDesc <HPSwiftTypeSpecificDesc>
@end
