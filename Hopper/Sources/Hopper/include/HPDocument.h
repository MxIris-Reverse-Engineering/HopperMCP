//
// Hopper Disassembler SDK
//
// (c) Cryptic Apps SARL. All Rights Reserved.
// https://www.hopperapp.com
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//

#import <Foundation/Foundation.h>
#import "CommonTypes.h"

@protocol HPDisassembledFile;
@protocol HPSegment;
@protocol HPSection;

@class NSWindow;

typedef void (^CancelBlock)(void);

@protocol HPDocument <NSObject>

- (nullable id<HPDisassembledFile>)disassembledFile;
- (nullable id<HPSegment>)currentSegment;
- (nullable id<HPSection>)currentSection;

// Cursor position, and moving without the navigation stack
- (Address)currentAddress;
- (AddressRange)selectedAddressRange;
- (void)moveCursorToVirtualAddress:(Address)a;
- (void)moveCursorToVirtualAddressRange:(AddressRange)range;

// Moving using navigation stack
- (void)gotoVirtualAddress:(Address)virtualAddress;
- (BOOL)gotoVirtualAddressString:(nonnull NSString *)virtualAddressString;
- (void)popAddressFromNavigationStack;

// Background process
- (void)waitForBackgroundProcessToEnd;
- (BOOL)backgroundProcessActive;
- (void)requestBackgroundProcessStop;

// Determines if the user can interact with the document
- (BOOL)isWaiting;
- (void)beginToWait:(nullable NSString *)message;
- (void)beginToWait:(nullable NSString *)message cancelBlock:(nullable CancelBlock)block;
- (void)endWaiting;

// Display message
- (void)logStringMessage:(nonnull NSString *)message;
- (void)logErrorStringMessage:(nonnull NSString *)message;
- (void)logInfoMessage:(nonnull NSString *)message;
- (NSInteger)displayAlertWithMessageText:(nonnull NSString *)text
                           defaultButton:(nonnull NSString *)defaultButton
                         alternateButton:(nullable NSString *)alternateButton
                             otherButton:(nullable NSString *)otherButton
                         informativeText:(nullable NSString *)message;

// Reading and modifying file
// These operations are performed in the endianess of the CPU module attached
// to the file. During the loading process, you should NOT use these methods,
// as no CPU plugin is attached at this stage!
- (int8_t)readInt8AtVirtualAddress:(Address)virtualAddress;
- (int16_t)readInt16AtVirtualAddress:(Address)virtualAddress;
- (int32_t)readInt32AtVirtualAddress:(Address)virtualAddress;
- (int64_t)readInt64AtVirtualAddress:(Address)virtualAddress;
- (uint8_t)readUInt8AtVirtualAddress:(Address)virtualAddress;
- (uint16_t)readUInt16AtVirtualAddress:(Address)virtualAddress;
- (uint32_t)readUInt32AtVirtualAddress:(Address)virtualAddress;
- (uint64_t)readUInt64AtVirtualAddress:(Address)virtualAddress;
- (Address)readAddressAtVirtualAddress:(Address)virtualAddress;

- (nullable NSString *)readCStringAt:(Address)virtualAddress;

- (BOOL)writeInt8:(int8_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeInt16:(int16_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeInt32:(int32_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeInt64:(int64_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeUInt8:(uint8_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeUInt16:(uint16_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeUInt32:(uint32_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeUInt64:(uint64_t)value atVirtualAddress:(Address)virtualAddress;
- (BOOL)writeAddress:(Address)value atVirtualAddress:(Address)virtualAddress;

// Global UI
- (void)updateUI;
- (nonnull NSWindow *)windowForSheet;

@end
