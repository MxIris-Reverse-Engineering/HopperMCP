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

#ifndef _HOPPER_DISASM_STRUCT_H_
#define _HOPPER_DISASM_STRUCT_H_

#include <stdint.h>
#include "CommonTypes.h"

#define DISASM_INSTRUCTION_MAX_LENGTH 2048

#define DISASM_UNKNOWN_OPCODE -1

#define DISASM_MAX_OPERANDS                             6
#define DISASM_MAX_REG_INDEX                            32
#define DISASM_MAX_REG_CLASSES                          16
#define DISASM_MAX_USER_DATA                            32

#define DISASM_OPERAND_REGISTER_INDEX_MASK              0x00000000FFFFFFFFllu
#define DISASM_OPERAND_TYPE_MASK                        0xFFFF000000000000llu
#define DISASM_OPERAND_MAIN_TYPE_MASK                   0xF000000000000000llu
#define DISASM_OPERAND_TYPE_OPTIONS_MASK                0x0F00000000000000llu
#define DISASM_OPERAND_REG_CLASS_MASK                   0x0000FFFF00000000llu
#define DISASM_OPERAND_TYPE_AND_REG_CLASS_MASK          0xFFFFFFFF00000000llu

// Type
/// Operand unused
#define DISASM_OPERAND_NO_OPERAND                       0x8000000000000000llu
/// A constant value (in the immediate field). Can be tagged as absolute, or relative (for instance, for JMP addresses). By default, value is an integer, but it can be a float if tag is present.
#define DISASM_OPERAND_CONSTANT_TYPE                    0x4000000000000000llu
/// A memory access
#define DISASM_OPERAND_MEMORY_TYPE                      0x2000000000000000llu
/// A set a registers
#define DISASM_OPERAND_REGISTER_TYPE                    0x1000000000000000llu
/// For constant values: this value is absolute
#define DISASM_OPERAND_ABSOLUTE                         0x0800000000000000llu
/// For constant values: this value is relative
#define DISASM_OPERAND_RELATIVE                         0x0400000000000000llu
/// For constant values: this is a floating point value
#define DISASM_OPERAND_FLOAT_CONSTANT                   0x0200000000000000llu
/// An unidentified type, store as a plain raw string in userString
#define DISASM_OPERAND_OTHER                            0x0100000000000000llu

#define DISASM_BUILD_REGISTER_CLS_MASK(CLS)             (0x100000000llu << (CLS))
#define DISASM_BUILD_REGISTER_INDEX_MASK(INDEX)         (1llu << (INDEX))
#define DISASM_BUILD_REGISTER_MASK(CLS,INDEX)           (DISASM_BUILD_REGISTER_CLS_MASK(CLS) | DISASM_BUILD_REGISTER_INDEX_MASK(INDEX))

#define DISASM_GET_REGISTER_CLS_MASK(TYPE)              (((TYPE) & DISASM_OPERAND_REG_CLASS_MASK) >> DISASM_MAX_REG_INDEX)
#define DISASM_GET_REGISTER_INDEX_MASK(TYPE)            ((TYPE) & DISASM_OPERAND_REGISTER_INDEX_MASK)

#define DISASM_OPERAND_GENERAL_REG_INDEX                2

// Register class (x86)
#define DISASM_OPERAND_X86_FPU_REG_INDEX                3
#define DISASM_OPERAND_X86_MMX_REG_INDEX                4
#define DISASM_OPERAND_X86_SSE_REG_INDEX                5
#define DISASM_OPERAND_X86_AVX_REG_INDEX                6
#define DISASM_OPERAND_X86_CR_REG_INDEX                 7
#define DISASM_OPERAND_X86_DR_REG_INDEX                 8
#define DISASM_OPERAND_X86_SPECIAL_REG_INDEX            9
#define DISASM_OPERAND_X86_MEMORY_MANAGEMENT_REG_INDEX  10
#define DISASM_OPERAND_X86_SEGMENT_REG_INDEX            11

#define DISASM_OPERAND_GENERAL_REG                      DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_GENERAL_REG_INDEX)
#define DISASM_OPERAND_X86_FPU_REG                      DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_FPU_REG_INDEX)
#define DISASM_OPERAND_X86_MMX_REG                      DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_MMX_REG_INDEX)
#define DISASM_OPERAND_X86_SSE_REG                      DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_SSE_REG_INDEX)
#define DISASM_OPERAND_X86_AVX_REG                      DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_AVX_REG_INDEX)
#define DISASM_OPERAND_X86_CR_REG                       DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_CR_REG_INDEX)
#define DISASM_OPERAND_X86_DR_REG                       DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_DR_REG_INDEX)
#define DISASM_OPERAND_X86_SPECIAL_REG                  DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_SPECIAL_REG_INDEX)
#define DISASM_OPERAND_X86_MEMORY_MANAGEMENT_REG        DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_MEMORY_MANAGEMENT_REG_INDEX)
#define DISASM_OPERAND_X86_SEGMENT_REG                  DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_X86_SEGMENT_REG_INDEX)

// Register class (ARM)
#define DISASM_OPERAND_ARM_VFP_SINGLE_REG_INDEX         3
#define DISASM_OPERAND_ARM_VFP_DOUBLE_REG_INDEX         4
#define DISASM_OPERAND_ARM_VFP_QUAD_REG_INDEX           5
#define DISASM_OPERAND_ARM_MEDIA_REG_INDEX              6
#define DISASM_OPERAND_ARM_SPECIAL_REG_INDEX            7

#define DISASM_OPERAND_ARM_VFP_SINGLE_REG               DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_ARM_VFP_SINGLE_REG_INDEX)
#define DISASM_OPERAND_ARM_VFP_DOUBLE_REG               DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_ARM_VFP_DOUBLE_REG_INDEX)
#define DISASM_OPERAND_ARM_VFP_QUAD_REG                 DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_ARM_VFP_QUAD_REG_INDEX)
#define DISASM_OPERAND_ARM_MEDIA_REG                    DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_ARM_MEDIA_REG_INDEX)
#define DISASM_OPERAND_ARM_SPECIAL_REG                  DISASM_BUILD_REGISTER_CLS_MASK(DISASM_OPERAND_ARM_SPECIAL_REG_INDEX)

#define DISASM_REG0  DISASM_BUILD_REGISTER_INDEX_MASK(0)
#define DISASM_REG1  DISASM_BUILD_REGISTER_INDEX_MASK(1)
#define DISASM_REG2  DISASM_BUILD_REGISTER_INDEX_MASK(2)
#define DISASM_REG3  DISASM_BUILD_REGISTER_INDEX_MASK(3)
#define DISASM_REG4  DISASM_BUILD_REGISTER_INDEX_MASK(4)
#define DISASM_REG5  DISASM_BUILD_REGISTER_INDEX_MASK(5)
#define DISASM_REG6  DISASM_BUILD_REGISTER_INDEX_MASK(6)
#define DISASM_REG7  DISASM_BUILD_REGISTER_INDEX_MASK(7)
#define DISASM_REG8  DISASM_BUILD_REGISTER_INDEX_MASK(8)
#define DISASM_REG9  DISASM_BUILD_REGISTER_INDEX_MASK(9)
#define DISASM_REG10 DISASM_BUILD_REGISTER_INDEX_MASK(10)
#define DISASM_REG11 DISASM_BUILD_REGISTER_INDEX_MASK(11)
#define DISASM_REG12 DISASM_BUILD_REGISTER_INDEX_MASK(12)
#define DISASM_REG13 DISASM_BUILD_REGISTER_INDEX_MASK(13)
#define DISASM_REG14 DISASM_BUILD_REGISTER_INDEX_MASK(14)
#define DISASM_REG15 DISASM_BUILD_REGISTER_INDEX_MASK(15)
#define DISASM_REG16 DISASM_BUILD_REGISTER_INDEX_MASK(16)
#define DISASM_REG17 DISASM_BUILD_REGISTER_INDEX_MASK(17)
#define DISASM_REG18 DISASM_BUILD_REGISTER_INDEX_MASK(18)
#define DISASM_REG19 DISASM_BUILD_REGISTER_INDEX_MASK(19)
#define DISASM_REG20 DISASM_BUILD_REGISTER_INDEX_MASK(20)
#define DISASM_REG21 DISASM_BUILD_REGISTER_INDEX_MASK(21)
#define DISASM_REG22 DISASM_BUILD_REGISTER_INDEX_MASK(22)
#define DISASM_REG23 DISASM_BUILD_REGISTER_INDEX_MASK(23)
#define DISASM_REG24 DISASM_BUILD_REGISTER_INDEX_MASK(24)
#define DISASM_REG25 DISASM_BUILD_REGISTER_INDEX_MASK(25)
#define DISASM_REG26 DISASM_BUILD_REGISTER_INDEX_MASK(26)
#define DISASM_REG27 DISASM_BUILD_REGISTER_INDEX_MASK(27)
#define DISASM_REG28 DISASM_BUILD_REGISTER_INDEX_MASK(28)
#define DISASM_REG29 DISASM_BUILD_REGISTER_INDEX_MASK(29)
#define DISASM_REG30 DISASM_BUILD_REGISTER_INDEX_MASK(30)
#define DISASM_REG31 DISASM_BUILD_REGISTER_INDEX_MASK(31)

typedef uint64_t DisasmOperandType;

typedef enum {
    DISASM_LOWPOSITION,
    DISASM_HIGHPOSITION
} DisasmPosition;

typedef enum {
    //// The flag is tested
    DISASM_EFLAGS_TESTED    = 0x01,
    //// The flag is modified
    DISASM_EFLAGS_MODIFIED  = 0x02,
    //// The flag is reset
    DISASM_EFLAGS_RESET     = 0x04,
    //// The flag is set
    DISASM_EFLAGS_SET       = 0x08,
    //// Undefined behavior
    DISASM_EFLAGS_UNDEFINED = 0x10,
    //// Restore prior state
    DISASM_EFLAGS_PRIOR     = 0x20
} DisasmEflagsState;

typedef enum {
    /// Jump if not overflow
    DISASM_BRANCH_JNO = -1,
    /// Jump if not carry
    DISASM_BRANCH_JNC = -2,
    /// Jump if not below
    DISASM_BRANCH_JNB = DISASM_BRANCH_JNC,
    /// Jump if not equal
    DISASM_BRANCH_JNE = -3,
    /// Jump if not above
    DISASM_BRANCH_JNA = -4,
    /// Jump if not sign
    DISASM_BRANCH_JNS = -5,
    /// Jump if not parity
    DISASM_BRANCH_JNP = -6,
    /// Jump if not less
    DISASM_BRANCH_JNL = -7,
    /// Jump if not greater
    DISASM_BRANCH_JNG = -8,

    DISASM_BRANCH_NONE = 0,

    /// Jump if overflow (OF=1)
    DISASM_BRANCH_JO = 1,
    /// Jump if carry (CF=1)
    DISASM_BRANCH_JC = 2,
    /// Jump if below (CF=1)
    DISASM_BRANCH_JB = DISASM_BRANCH_JC,
    /// Jump if equal (ZF=1)
    DISASM_BRANCH_JE = 3,
    /// Jump if above (CF=0 and ZF=0)
    DISASM_BRANCH_JA = 4,
    /// Jump if sign (SF=1)
    DISASM_BRANCH_JS = 5,
    /// Jump if parity even (PF=1)
    DISASM_BRANCH_JP = 6,
    /// Jump if less (SF != OF)
    DISASM_BRANCH_JL = 7,
    /// Jump if greater (ZF=0 and SF=OF)
    DISASM_BRANCH_JG = 8,
    /// Jump if lower or equal (i.e. not greater)
    DISASM_BRANCH_JLE = DISASM_BRANCH_JNG,
    /// Jump if greater or equal (i.e. not lower)
    DISASM_BRANCH_JGE = DISASM_BRANCH_JNL,

    /// Jump if CX is zero
    DISASM_BRANCH_JCXZ = 10,
    /// Jump if ECX is zero
    DISASM_BRANCH_JECXZ = 11,
    /// Jump if RCX is zero
    DISASM_BRANCH_JRCXZ = 12,

    DISASM_BRANCH_JMP = 13,
    DISASM_BRANCH_CALL = 14,
    DISASM_BRANCH_RET = 15
} DisasmBranchType;

typedef enum {
    DISASM_INST_COND_AL,
    DISASM_INST_COND_EQ,
    DISASM_INST_COND_NE,
    DISASM_INST_COND_CS,
    DISASM_INST_COND_CC,
    DISASM_INST_COND_MI,
    DISASM_INST_COND_PL,
    DISASM_INST_COND_VS,
    DISASM_INST_COND_VC,
    DISASM_INST_COND_HI,
    DISASM_INST_COND_LS,
    DISASM_INST_COND_GE,
    DISASM_INST_COND_LT,
    DISASM_INST_COND_GT,
    DISASM_INST_COND_LE,

    DISASM_INST_COND_NEVER
} DisasmCondition;

typedef enum {
    DISASM_SHIFT_NONE,
    DISASM_SHIFT_LSL,
    DISASM_SHIFT_LSR,
    DISASM_SHIFT_ASR,
    DISASM_SHIFT_ROR,
    DISASM_SHIFT_RRX,
    DISASM_SHIFT_MSL
} DisasmShiftMode;

typedef enum {
    DISASM_EXT_NONE,
    DISASM_EXT_UXTB,
    DISASM_EXT_UXTH,
    DISASM_EXT_UXTW,
    DISASM_EXT_UXTX,
    DISASM_EXT_SXTB,
    DISASM_EXT_SXTH,
    DISASM_EXT_SXTW,
    DISASM_EXT_SXTX
} DisasmExtMode;

typedef enum {
    DISASM_ACCESS_NONE  =  0x0,
    DISASM_ACCESS_READ  =  0x1,
    DISASM_ACCESS_WRITE =  0x2
} DisasmAccessMode;

enum {
    DISASM_REG_INDEX_RAX, DISASM_REG_INDEX_RCX, DISASM_REG_INDEX_RDX, DISASM_REG_INDEX_RBX,
    DISASM_REG_INDEX_RSP, DISASM_REG_INDEX_RBP, DISASM_REG_INDEX_RSI, DISASM_REG_INDEX_RDI,
    DISASM_REG_INDEX_R8,  DISASM_REG_INDEX_R9,  DISASM_REG_INDEX_R10, DISASM_REG_INDEX_R11,
    DISASM_REG_INDEX_R12, DISASM_REG_INDEX_R13, DISASM_REG_INDEX_R14, DISASM_REG_INDEX_R15,
    DISASM_REG_INDEX_RIP
};

typedef enum {
    DISASM_ES_Reg = 1,
    DISASM_DS_Reg = 2,
    DISASM_FS_Reg = 3,
    DISASM_GS_Reg = 4,
    DISASM_CS_Reg = 5,
    DISASM_SS_Reg = 6
} DisasmSegmentReg;

typedef struct {
    unsigned lockPrefix : 1;
    unsigned repnePrefix : 1;
    unsigned repPrefix : 1;
    unsigned bndPrefix : 1;
    unsigned segmentOverride : 4;
} DisasmPrefix;

typedef struct {
    DisasmEflagsState OF_flag;
    DisasmEflagsState SF_flag;
    DisasmEflagsState ZF_flag;
    DisasmEflagsState AF_flag;
    DisasmEflagsState PF_flag;
    DisasmEflagsState CF_flag;
    DisasmEflagsState TF_flag;
    DisasmEflagsState IF_flag;
    DisasmEflagsState DF_flag;
    DisasmEflagsState NT_flag;
    DisasmEflagsState RF_flag;
} DisasmEFLAGS;

typedef struct {
    /// ARM specific. Set to 1 if 'S' flag.
    unsigned ARMSBit : 1;
    /// ARM specific: Set to 1 if writeback flag (!).
    unsigned ARMWriteBack : 1;
    /// ARM specific: Set to 1 if special flag (^).
    unsigned ARMSpecial : 1;
    /// ARM specifig: Set to 1 if thumb instruction.
    unsigned ARMThumb : 1;

    /// The instruction may change the next instruction CPU mode.
    unsigned changeNextInstrMode : 1;
} DisasmInstrFlags;

/// Define a memory access in the form [BASE_REGISTERS + (INDEX_REGISTERS) * SCALE + DISPLACEMENT]
typedef struct {
    /// Mask of the base registers used
    uint64_t    baseRegistersMask;
    /// Mask of the index registers used
    uint64_t    indexRegistersMask;
    /// Scale (1, 2, 4, 8, ...)
    int32_t     scale;
    /// Displacement
    int64_t     displacement;
} DisasmMemoryAccess;

typedef struct  {
    /// Instruction mnemonic, with its optional condition.
    char                mnemonic[32];

    /// Mnemonic string without the conditional part.
    char                unconditionalMnemonic[32];
    /// Condition to be met to execute instruction.
    DisasmCondition     condition;

    /// A field that you can use internally to keep information on the instruction. Hopper don't need
    uintptr_t           userData;

    /// Length in bytes of the instruction encoding.
    uint8_t             length;

    /// Information on the type of branch this instruction can perform.
    DisasmBranchType    branchType;
    /// Information on the CPU state register after this instruction is executed.
    DisasmEFLAGS        eflags;
    /// A value computed from one of the operands, known to point to an address.
    Address             addressValue;

    /// The value of the PC register at this address.
    /// For instance, on the Intel processor, it will be the address of the instruction + the length of the instruction.
    /// For the ARM processor, it will be the address of the instruction + 4 or 8, depending on various things.
    /// Anyway, it must reflects the exact value of the PC register if read from the instruction.
    Address             pcRegisterValue;

    DisasmInstrFlags    specialFlags;
} DisasmInstruction;

typedef struct {
    /// Mask of DISASM_OPERAND_* values.
    DisasmOperandType  type;
    /// Argument size in bits. In the case of a memory access, this is the size of the read or written value.
    uint32_t           size;
    /// Whether the operand is accessed for reading or writing. DISASM_ACCESS_READ / DISASM_ACCESS_WRITE
    DisasmAccessMode   accessMode;

    /// DISASM_HIGHPOSITION / DISASM_LOWPOSITION: high position if for 8bits registers AH, BH, CH, DH
    DisasmPosition     position;

    /// X86 specific: the segment register used for the memory access.
    DisasmSegmentReg   segmentReg;
    /// Description of the memory indirection.
    DisasmMemoryAccess memory;
    /// Used for decoration on memory operands, like "dword ptr"… This is a plugin specific value, Hopper doesn't need it.
    int8_t             memoryDecoration;

    /// Shifting used when the type is DISASM_OPERAND_REGISTER_TYPE
    /// Shifting mode
    DisasmShiftMode    shiftMode;
    /// Extension mode
    DisasmExtMode      extMode;
    /// Shifting amount (if not shifted by a register)
    int32_t            shiftAmount;
    /// Shifting register
    int32_t            shiftByReg;

    union {
        /// The immediate value for this operand, if known.
        int64_t            immediateValue;
        double             immediateDoubleValue;
    };

    /// A value different from 0 if the operand is used to compute a destination address for a branch instruction
    uint8_t            isBranchDestination;

    union {
        /// You can use this field to store important informations, Hopper will not use it.
        uint64_t       userData[DISASM_MAX_USER_DATA];
        char           userString[DISASM_MAX_USER_DATA * 8];
    };
} DisasmOperand;

typedef struct {
    /// Address where you can read the bytes to be decoded. Set by Hopper.
    const uint8_t *   bytes;

    /// Virtual address in the disassembled file space. Set by Hopper.
    Address           virtualAddr;

    /// Syntax to be used when building the various mnemonics.
    uint8_t           syntaxIndex;

    /// You can set the CPU, CPUSubType to any value during the initialization of the structure.
    /// These values are only used by plugins for their own purpose. Hopper don't need them.
    int32_t           CPU;
    int32_t           CPUSubType;
    CPUEndianess      endianess;

    /// Fields to be set by the plugin.
    DisasmPrefix      prefix;
    DisasmInstruction instruction;

    /// Mask of registers implicitly read or written.
    uint32_t          implicitlyReadRegisters[DISASM_MAX_REG_CLASSES];
    uint32_t          implicitlyWrittenRegisters[DISASM_MAX_REG_CLASSES];

    /// Instruction operands description
    DisasmOperand     operand[DISASM_MAX_OPERANDS];
} DisasmStruct;

#endif
