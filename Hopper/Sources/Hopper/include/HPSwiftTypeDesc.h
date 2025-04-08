//
//  HPSwiftTypeDesc.h
//  Hopper
//
//  Created by JH on 2025/4/8.
//

#import <Foundation/Foundation.h>

@protocol HPSwiftStructDesc;
@protocol HPSwiftEnumDesc;
@protocol HPSwiftClassDesc;

@protocol HPSwiftTypeDesc <NSObject>

@property (nonatomic) unsigned long long descAddress;
@property (nonatomic) unsigned int flags;
@property (copy, nonatomic) NSString *context;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) unsigned long long fieldDescriptorAddress;
@property (nonatomic) unsigned long long metaDataAccessFunctionPointer;
@property (nonatomic) int genericArgumentCount;
@property (readonly) id<HPSwiftClassDesc> classDesc;
@property (readonly) id<HPSwiftStructDesc> structDesc;
@property (readonly) id<HPSwiftEnumDesc> enumDesc;

- (id)fields;
- (void)addField:(id)a0;
- (unsigned long long)typeKind;
- (BOOL)isUnique;
- (BOOL)isGeneric;
- (unsigned char)version;
- (unsigned short)kindSpecificFlags;
- (id)parentContextPrefix;

@end

@protocol HPSwiftTypeSpecificDesc <NSObject>

- (id)context;
- (id)initWithContext:(id)a0;

@end

@protocol HPSwiftEnumDesc <HPSwiftTypeSpecificDesc>
@end

@protocol HPSwiftStructDesc <HPSwiftTypeSpecificDesc>
@end

@protocol HPSwiftClassDesc <HPSwiftTypeSpecificDesc>
@end
