@class NSMutableAttributedString;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"
@interface PseudoCode : NSObject
+ (id)pseudoCodeWithString:(id)a0 forNode:(id)a1;
- (id)init;
- (void)appendString:(NSString *)a0;
- (void)appendString:(NSString *)a0 forNode:(id)a1;
- (void)appendKeywordString:(NSString *)a0 forNode:(id)a1;
- (void)appendTypeString:(NSString *)a0 forNode:(id)a1;
- (void)appendOperatorString:(NSString *)a0 forNode:(id)a1;
- (void)appendLabelString:(NSString *)a0 forNode:(id)a1;
- (void)appendFunctionNameString:(NSString *)a0 forNode:(id)a1;
- (void)appendVariableNameString:(NSString *)a0 forNode:(id)a1;
- (void)appendAddressString:(NSString *)a0 withValue:(NSUInteger)a1 forNode:(id)a2;
- (void)appendNumberString:(NSString *)a0 withValue:(int)a1 forNode:(id)a2;
- (void)appendEnumString:(NSString *)a0 withValue:(int)a1 andType:(id)a2 forNode:(id)a3;
- (void)appendComment:(id)a0;
- (void)appendComment:(id)a0 forNode:(id)a1;
- (void)insertPseudoCode:(id)a0 atIndex:(NSUInteger)a1;
- (void)insertAttributedString:(id)a0 atIndex:(NSUInteger)a1;
- (void)addAttribute:(id)a0 value:(id)a1 range:(NSRange)a2;
- (nonnull NSString *)string;
- (nonnull NSAttributedString *)attributedString;
- (void)setAttributedString:(id)a0;
- (void)appendAttributedString:(id)a0;
- (void)appendPseudoCode:(id)a0;
- (NSUInteger)length;
- (id)procedureTargetAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (id)procedureTargetAtIndex:(NSUInteger)a0;
- (id)astNodeAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (NSUInteger)originalLowestASMInstructionAtIndex:(NSUInteger)a0;
- (NSRange)rangeForASTNode:(id)a0;
- (NSRange)bestRangeForInstructionAddress:(NSUInteger)a0;
- (BOOL)targetIsAProcedureAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (BOOL)targetIsAProcedureAtIndex:(NSUInteger)a0 location:(NSUInteger *)a1 length:(NSUInteger *)a2;
- (NSUInteger)selectorTargetAddressAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (NSUInteger)selectorTargetAddressAtIndex:(NSUInteger)a0;
- (BOOL)targetIsASelectorAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (BOOL)targetIsASelectorAtIndex:(NSUInteger)a0 location:(NSUInteger *)a1 length:(NSUInteger *)a2;
- (id)messageTargetAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (id)messageTargetAtIndex:(NSUInteger)a0;
- (BOOL)targetIsAMessageAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (BOOL)targetIsAMessageAtIndex:(NSUInteger)a0 location:(NSUInteger *)a1 length:(NSUInteger *)a2;
- (BOOL)targetIsALabelAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (BOOL)targetIsALabelAtIndex:(NSUInteger)a0 location:(NSUInteger *)a1 length:(NSUInteger *)a2;
- (id)targetLabelAtIndex:(NSUInteger)a0 range:(NSRange *)a1;
- (id)targetLabelAtIndex:(NSUInteger)a0 location:(NSUInteger *)a1 length:(NSUInteger *)a2;
- (NSUInteger)labelAddressAtIndex:(NSUInteger)a0;
- (NSUInteger)indexForLabelNamed:(id)a0;
- (void)colorize;
- (id)description;

@end
#pragma clang diagnostic pop
