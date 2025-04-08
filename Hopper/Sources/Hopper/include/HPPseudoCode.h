#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

@protocol HPPseudoCode <NSObject>

+ (instancetype)pseudoCodeWithString:(id)string forNode:(id)node;
- (instancetype)init;
- (void)appendString:(NSString *)appendString;
- (void)appendString:(NSString *)appendString forNode:(id)node;
- (void)appendKeywordString:(NSString *)appendKeywordString forNode:(id)node;
- (void)appendTypeString:(NSString *)appendTypeString forNode:(id)node;
- (void)appendOperatorString:(NSString *)appendOperatorString forNode:(id)node;
- (void)appendLabelString:(NSString *)appendLabelString forNode:(id)node;
- (void)appendFunctionNameString:(NSString *)appendFunctionNameString forNode:(id)node;
- (void)appendVariableNameString:(NSString *)appendVariableNameString forNode:(id)node;
- (void)appendAddressString:(NSString *)appendAddressString withValue:(NSUInteger)value forNode:(id)node;
- (void)appendNumberString:(NSString *)appendNumberString withValue:(int)value forNode:(id)node;
- (void)appendEnumString:(NSString *)appendEnumString withValue:(int)value andType:(id)andType forNode:(id)node;
- (void)appendComment:(id)appendComment;
- (void)appendComment:(id)appendComment forNode:(id)node;
- (void)insertPseudoCode:(id)insertPseudoCode atIndex:(NSUInteger)atIndex;
- (void)insertAttributedString:(id)insertAttributedString atIndex:(NSUInteger)atIndex;
- (void)addAttribute:(id)addAttribute value:(id)value range:(NSRange)range;
- (nonnull NSString *)string;
- (nonnull NSAttributedString *)attributedString;
- (void)setAttributedString:(id)attributedString;
- (void)appendAttributedString:(id)appendAttributedString;
- (void)appendPseudoCode:(id)appendPseudoCode;
- (NSUInteger)length;
- (id)procedureTargetAtIndex:(NSUInteger)procedureTargetAtIndex range:(NSRange *)range;
- (id)procedureTargetAtIndex:(NSUInteger)procedureTargetAtIndex;
- (id)astNodeAtIndex:(NSUInteger)astNodeAtIndex range:(NSRange *)range;
- (NSUInteger)originalLowestASMInstructionAtIndex:(NSUInteger)originalLowestASMInstructionAtIndex;
- (NSRange)rangeForASTNode:(id)aSTNode;
- (NSRange)bestRangeForInstructionAddress:(NSUInteger)instructionAddress;
- (BOOL)targetIsAProcedureAtIndex:(NSUInteger)aProcedureAtIndex range:(NSRange *)range;
- (BOOL)targetIsAProcedureAtIndex:(NSUInteger)aProcedureAtIndex location:(NSUInteger *)location length:(NSUInteger *)length;
- (NSUInteger)selectorTargetAddressAtIndex:(NSUInteger)selectorTargetAddressAtIndex range:(NSRange *)range;
- (NSUInteger)selectorTargetAddressAtIndex:(NSUInteger)selectorTargetAddressAtIndex;
- (BOOL)targetIsASelectorAtIndex:(NSUInteger)aSelectorAtIndex range:(NSRange *)range;
- (BOOL)targetIsASelectorAtIndex:(NSUInteger)aSelectorAtIndex location:(NSUInteger *)location length:(NSUInteger *)length;
- (id)messageTargetAtIndex:(NSUInteger)messageTargetAtIndex range:(NSRange *)range;
- (id)messageTargetAtIndex:(NSUInteger)messageTargetAtIndex;
- (BOOL)targetIsAMessageAtIndex:(NSUInteger)aMessageAtIndex range:(NSRange *)range;
- (BOOL)targetIsAMessageAtIndex:(NSUInteger)aMessageAtIndex location:(NSUInteger *)location length:(NSUInteger *)length;
- (BOOL)targetIsALabelAtIndex:(NSUInteger)aLabelAtIndex range:(NSRange *)range;
- (BOOL)targetIsALabelAtIndex:(NSUInteger)aLabelAtIndex location:(NSUInteger *)location length:(NSUInteger *)length;
- (id)targetLabelAtIndex:(NSUInteger)targetLabelAtIndex range:(NSRange *)range;
- (id)targetLabelAtIndex:(NSUInteger)targetLabelAtIndex location:(NSUInteger *)location length:(NSUInteger *)length;
- (NSUInteger)labelAddressAtIndex:(NSUInteger)labelAddressAtIndex;
- (NSUInteger)indexForLabelNamed:(id)labelNamed;
- (void)colorize;
- (id)description;

@end

#pragma clang diagnostic pop
