//pub const SDL_HINT_DEFAULT: c_int = 0;
//pub const SDL_HINT_NORMAL: c_int = 1;
//pub const SDL_HINT_OVERRIDE: c_int = 2;
//pub const enum_SDL_HintPriority = c_uint;
pub const Priority = enum (c_uint) {
	default,
	normal,
	override,
};

//pub const SDL_HintPriority = enum_SDL_HintPriority;
//pub extern fn SDL_SetHintWithPriority(name: [*c]const u8, value: [*c]const u8, priority: SDL_HintPriority) SDL_bool;
pub extern fn SDL_SetHintWithPriority(name: [*c]const u8, value: [*c]const u8, priority: Priority) bool;
pub const setHintWithPriority = SDL_SetHintWithPriority;
//pub extern fn SDL_SetHint(name: [*c]const u8, value: [*c]const u8) SDL_bool;
pub extern fn SDL_SetHint(name: [*c]const u8, value: [*c]const u8) bool;
pub const setHint = SDL_SetHint;
//pub extern fn SDL_ResetHint(name: [*c]const u8) SDL_bool;
pub extern fn SDL_ResetHint(name: [*c]const u8) bool;
pub const resetHint = SDL_ResetHint;
//pub extern fn SDL_ResetHints() void;
pub extern fn SDL_ResetHints() void;
pub const resetHints = SDL_ResetHints;
//pub extern fn SDL_GetHint(name: [*c]const u8) [*c]const u8;
pub extern fn SDL_GetHint(name: [*c]const u8) [*c]const u8;
pub const getHint = SDL_GetHint;
//pub extern fn SDL_GetHintBoolean(name: [*c]const u8, default_value: SDL_bool) SDL_bool;
pub extern fn SDL_GetHintBoolean(name: [*c]const u8, default_value: bool) bool;
pub const getHintBoolean = SDL_GetHintBoolean;
//pub const SDL_HintCallback = ?*const fn (?*anyopaque, [*c]const u8, [*c]const u8, [*c]const u8) callconv(.C) void;
pub const Callback = ?*const fn (?*anyopaque, [*c]const u8, [*c]const u8, [*c]const u8) callconv(.C) void;
//pub extern fn SDL_AddHintCallback(name: [*c]const u8, callback: SDL_HintCallback, userdata: ?*anyopaque) SDL_bool;
pub extern fn SDL_AddHintCallback(name: [*c]const u8, callback: Callback, userdata: ?*anyopaque) bool;
pub const addHintCallback = SDL_AddHintCallback;
//pub extern fn SDL_RemoveHintCallback(name: [*c]const u8, callback: SDL_HintCallback, userdata: ?*anyopaque) void;
pub extern fn SDL_RemoveHintCallback(name: [*c]const u8, callback: Callback, userdata: ?*anyopaque) void;
pub const removeHintCallback = SDL_RemoveHintCallback;
//pub const __llvm__ = @as(c_int, 1);
//pub const __clang__ = @as(c_int, 1);
//pub const __clang_major__ = @as(c_int, 18);
//pub const __clang_minor__ = @as(c_int, 1);
//pub const __clang_patchlevel__ = @as(c_int, 6);
//pub const __clang_version__ = "18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __GNUC__ = @as(c_int, 4);
//pub const __GNUC_MINOR__ = @as(c_int, 2);
//pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
//pub const __GXX_ABI_VERSION = @as(c_int, 1002);
//pub const __ATOMIC_RELAXED = @as(c_int, 0);
//pub const __ATOMIC_CONSUME = @as(c_int, 1);
//pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
//pub const __ATOMIC_RELEASE = @as(c_int, 3);
//pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
//pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
//pub const __MEMORY_SCOPE_SYSTEM = @as(c_int, 0);
//pub const __MEMORY_SCOPE_DEVICE = @as(c_int, 1);
//pub const __MEMORY_SCOPE_WRKGRP = @as(c_int, 2);
//pub const __MEMORY_SCOPE_WVFRNT = @as(c_int, 3);
//pub const __MEMORY_SCOPE_SINGLE = @as(c_int, 4);
//pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
//pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
//pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
//pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
//pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
//pub const __FPCLASS_SNAN = @as(c_int, 0x0001);
//pub const __FPCLASS_QNAN = @as(c_int, 0x0002);
//pub const __FPCLASS_NEGINF = @as(c_int, 0x0004);
//pub const __FPCLASS_NEGNORMAL = @as(c_int, 0x0008);
//pub const __FPCLASS_NEGSUBNORMAL = @as(c_int, 0x0010);
//pub const __FPCLASS_NEGZERO = @as(c_int, 0x0020);
//pub const __FPCLASS_POSZERO = @as(c_int, 0x0040);
//pub const __FPCLASS_POSSUBNORMAL = @as(c_int, 0x0080);
//pub const __FPCLASS_POSNORMAL = @as(c_int, 0x0100);
//pub const __FPCLASS_POSINF = @as(c_int, 0x0200);
//pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
//pub const __VERSION__ = "Clang 18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
//pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
//pub const __SEH__ = @as(c_int, 1);
//pub const __clang_literal_encoding__ = "UTF-8";
//pub const __clang_wide_literal_encoding__ = "UTF-16";
//pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
//pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
//pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
//pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
//pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
//pub const __CHAR_BIT__ = @as(c_int, 8);
//pub const __BOOL_WIDTH__ = @as(c_int, 8);
//pub const __SHRT_WIDTH__ = @as(c_int, 16);
//pub const __INT_WIDTH__ = @as(c_int, 32);
//pub const __LONG_WIDTH__ = @as(c_int, 32);
//pub const __LLONG_WIDTH__ = @as(c_int, 64);
//pub const __BITINT_MAXWIDTH__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 8388608, .decimal);
//pub const __SCHAR_MAX__ = @as(c_int, 127);
//pub const __SHRT_MAX__ = @as(c_int, 32767);
//pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __LONG_MAX__ = @as(c_long, 2147483647);
//pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WCHAR_WIDTH__ = @as(c_int, 16);
//pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WINT_WIDTH__ = @as(c_int, 16);
//pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTMAX_WIDTH__ = @as(c_int, 64);
//pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __SIZE_WIDTH__ = @as(c_int, 64);
//pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
//pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
//pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTPTR_WIDTH__ = @as(c_int, 64);
//pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
//pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
//pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
//pub const __SIZEOF_INT__ = @as(c_int, 4);
//pub const __SIZEOF_LONG__ = @as(c_int, 4);
//pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
//pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
//pub const __SIZEOF_POINTER__ = @as(c_int, 8);
//pub const __SIZEOF_SHORT__ = @as(c_int, 2);
//pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
//pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
//pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
//pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
//pub const __SIZEOF_INT128__ = @as(c_int, 16);
//pub const __INTMAX_TYPE__ = c_longlong;
//pub const __INTMAX_FMTd__ = "lld";
//pub const __INTMAX_FMTi__ = "lli";
//pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):94:9
//pub const __UINTMAX_TYPE__ = c_ulonglong;
//pub const __UINTMAX_FMTo__ = "llo";
//pub const __UINTMAX_FMTu__ = "llu";
//pub const __UINTMAX_FMTx__ = "llx";
//pub const __UINTMAX_FMTX__ = "llX";
//pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):100:9
//pub const __PTRDIFF_TYPE__ = c_longlong;
//pub const __PTRDIFF_FMTd__ = "lld";
//pub const __PTRDIFF_FMTi__ = "lli";
//pub const __INTPTR_TYPE__ = c_longlong;
//pub const __INTPTR_FMTd__ = "lld";
//pub const __INTPTR_FMTi__ = "lli";
//pub const __SIZE_TYPE__ = c_ulonglong;
//pub const __SIZE_FMTo__ = "llo";
//pub const __SIZE_FMTu__ = "llu";
//pub const __SIZE_FMTx__ = "llx";
//pub const __SIZE_FMTX__ = "llX";
//pub const __WCHAR_TYPE__ = c_ushort;
//pub const __WINT_TYPE__ = c_ushort;
//pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
//pub const __CHAR16_TYPE__ = c_ushort;
//pub const __CHAR32_TYPE__ = c_uint;
//pub const __UINTPTR_TYPE__ = c_ulonglong;
//pub const __UINTPTR_FMTo__ = "llo";
//pub const __UINTPTR_FMTu__ = "llu";
//pub const __UINTPTR_FMTx__ = "llx";
//pub const __UINTPTR_FMTX__ = "llX";
//pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
//pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT16_DIG__ = @as(c_int, 3);
//pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
//pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
//pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
//pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
//pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
//pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
//pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
//pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
//pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
//pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
//pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT_DIG__ = @as(c_int, 6);
//pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
//pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
//pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT_MANT_DIG__ = @as(c_int, 24);
//pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
//pub const __FLT_MAX_EXP__ = @as(c_int, 128);
//pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
//pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
//pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
//pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
//pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
//pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __DBL_DIG__ = @as(c_int, 15);
//pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
//pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
//pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __DBL_MANT_DIG__ = @as(c_int, 53);
//pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
//pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
//pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
//pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
//pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
//pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
//pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
//pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __LDBL_DIG__ = @as(c_int, 18);
//pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
//pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
//pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
//pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
//pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
//pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
//pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
//pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
//pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
//pub const __POINTER_WIDTH__ = @as(c_int, 64);
//pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
//pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
//pub const __WINT_UNSIGNED__ = @as(c_int, 1);
//pub const __INT8_TYPE__ = i8;
//pub const __INT8_FMTd__ = "hhd";
//pub const __INT8_FMTi__ = "hhi";
//pub const __INT8_C_SUFFIX__ = "";
//pub const __INT16_TYPE__ = c_short;
//pub const __INT16_FMTd__ = "hd";
//pub const __INT16_FMTi__ = "hi";
//pub const __INT16_C_SUFFIX__ = "";
//pub const __INT32_TYPE__ = c_int;
//pub const __INT32_FMTd__ = "d";
//pub const __INT32_FMTi__ = "i";
//pub const __INT32_C_SUFFIX__ = "";
//pub const __INT64_TYPE__ = c_longlong;
//pub const __INT64_FMTd__ = "lld";
//pub const __INT64_FMTi__ = "lli";
//pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):198:9
//pub const __UINT8_TYPE__ = u8;
//pub const __UINT8_FMTo__ = "hho";
//pub const __UINT8_FMTu__ = "hhu";
//pub const __UINT8_FMTx__ = "hhx";
//pub const __UINT8_FMTX__ = "hhX";
//pub const __UINT8_C_SUFFIX__ = "";
//pub const __UINT8_MAX__ = @as(c_int, 255);
//pub const __INT8_MAX__ = @as(c_int, 127);
//pub const __UINT16_TYPE__ = c_ushort;
//pub const __UINT16_FMTo__ = "ho";
//pub const __UINT16_FMTu__ = "hu";
//pub const __UINT16_FMTx__ = "hx";
//pub const __UINT16_FMTX__ = "hX";
//pub const __UINT16_C_SUFFIX__ = "";
//pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __INT16_MAX__ = @as(c_int, 32767);
//pub const __UINT32_TYPE__ = c_uint;
//pub const __UINT32_FMTo__ = "o";
//pub const __UINT32_FMTu__ = "u";
//pub const __UINT32_FMTx__ = "x";
//pub const __UINT32_FMTX__ = "X";
//pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
//// (no file):220:9
//pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __UINT64_TYPE__ = c_ulonglong;
//pub const __UINT64_FMTo__ = "llo";
//pub const __UINT64_FMTu__ = "llu";
//pub const __UINT64_FMTx__ = "llx";
//pub const __UINT64_FMTX__ = "llX";
//pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):228:9
//pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST8_TYPE__ = i8;
//pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
//pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_LEAST8_FMTd__ = "hhd";
//pub const __INT_LEAST8_FMTi__ = "hhi";
//pub const __UINT_LEAST8_TYPE__ = u8;
//pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_LEAST8_FMTo__ = "hho";
//pub const __UINT_LEAST8_FMTu__ = "hhu";
//pub const __UINT_LEAST8_FMTx__ = "hhx";
//pub const __UINT_LEAST8_FMTX__ = "hhX";
//pub const __INT_LEAST16_TYPE__ = c_short;
//pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_LEAST16_FMTd__ = "hd";
//pub const __INT_LEAST16_FMTi__ = "hi";
//pub const __UINT_LEAST16_TYPE__ = c_ushort;
//pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_LEAST16_FMTo__ = "ho";
//pub const __UINT_LEAST16_FMTu__ = "hu";
//pub const __UINT_LEAST16_FMTx__ = "hx";
//pub const __UINT_LEAST16_FMTX__ = "hX";
//pub const __INT_LEAST32_TYPE__ = c_int;
//pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_LEAST32_FMTd__ = "d";
//pub const __INT_LEAST32_FMTi__ = "i";
//pub const __UINT_LEAST32_TYPE__ = c_uint;
//pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_LEAST32_FMTo__ = "o";
//pub const __UINT_LEAST32_FMTu__ = "u";
//pub const __UINT_LEAST32_FMTx__ = "x";
//pub const __UINT_LEAST32_FMTX__ = "X";
//pub const __INT_LEAST64_TYPE__ = c_longlong;
//pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_LEAST64_FMTd__ = "lld";
//pub const __INT_LEAST64_FMTi__ = "lli";
//pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
//pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_LEAST64_FMTo__ = "llo";
//pub const __UINT_LEAST64_FMTu__ = "llu";
//pub const __UINT_LEAST64_FMTx__ = "llx";
//pub const __UINT_LEAST64_FMTX__ = "llX";
//pub const __INT_FAST8_TYPE__ = i8;
//pub const __INT_FAST8_MAX__ = @as(c_int, 127);
//pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_FAST8_FMTd__ = "hhd";
//pub const __INT_FAST8_FMTi__ = "hhi";
//pub const __UINT_FAST8_TYPE__ = u8;
//pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_FAST8_FMTo__ = "hho";
//pub const __UINT_FAST8_FMTu__ = "hhu";
//pub const __UINT_FAST8_FMTx__ = "hhx";
//pub const __UINT_FAST8_FMTX__ = "hhX";
//pub const __INT_FAST16_TYPE__ = c_short;
//pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_FAST16_FMTd__ = "hd";
//pub const __INT_FAST16_FMTi__ = "hi";
//pub const __UINT_FAST16_TYPE__ = c_ushort;
//pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_FAST16_FMTo__ = "ho";
//pub const __UINT_FAST16_FMTu__ = "hu";
//pub const __UINT_FAST16_FMTx__ = "hx";
//pub const __UINT_FAST16_FMTX__ = "hX";
//pub const __INT_FAST32_TYPE__ = c_int;
//pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_FAST32_FMTd__ = "d";
//pub const __INT_FAST32_FMTi__ = "i";
//pub const __UINT_FAST32_TYPE__ = c_uint;
//pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_FAST32_FMTo__ = "o";
//pub const __UINT_FAST32_FMTu__ = "u";
//pub const __UINT_FAST32_FMTx__ = "x";
//pub const __UINT_FAST32_FMTX__ = "X";
//pub const __INT_FAST64_TYPE__ = c_longlong;
//pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_FAST64_FMTd__ = "lld";
//pub const __INT_FAST64_FMTi__ = "lli";
//pub const __UINT_FAST64_TYPE__ = c_ulonglong;
//pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_FAST64_FMTo__ = "llo";
//pub const __UINT_FAST64_FMTu__ = "llu";
//pub const __UINT_FAST64_FMTx__ = "llx";
//pub const __UINT_FAST64_FMTX__ = "llX";
//pub const __USER_LABEL_PREFIX__ = "";
//pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
//pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
//pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
//pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __NO_INLINE__ = @as(c_int, 1);
//pub const __PIC__ = @as(c_int, 2);
//pub const __pic__ = @as(c_int, 2);
//pub const __FLT_RADIX__ = @as(c_int, 2);
//pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
//pub const __SSP_STRONG__ = @as(c_int, 2);
//pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
//pub const __code_model_small__ = @as(c_int, 1);
//pub const __amd64__ = @as(c_int, 1);
//pub const __amd64 = @as(c_int, 1);
//pub const __x86_64 = @as(c_int, 1);
//pub const __x86_64__ = @as(c_int, 1);
//pub const __SEG_GS = @as(c_int, 1);
//pub const __SEG_FS = @as(c_int, 1);
//pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):357:9
//pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):358:9
//pub const __k8 = @as(c_int, 1);
//pub const __k8__ = @as(c_int, 1);
//pub const __tune_k8__ = @as(c_int, 1);
//pub const __REGISTER_PREFIX__ = "";
//pub const __NO_MATH_INLINES = @as(c_int, 1);
//pub const __AES__ = @as(c_int, 1);
//pub const __VAES__ = @as(c_int, 1);
//pub const __PCLMUL__ = @as(c_int, 1);
//pub const __VPCLMULQDQ__ = @as(c_int, 1);
//pub const __LAHF_SAHF__ = @as(c_int, 1);
//pub const __LZCNT__ = @as(c_int, 1);
//pub const __RDRND__ = @as(c_int, 1);
//pub const __FSGSBASE__ = @as(c_int, 1);
//pub const __BMI__ = @as(c_int, 1);
//pub const __BMI2__ = @as(c_int, 1);
//pub const __POPCNT__ = @as(c_int, 1);
//pub const __PRFCHW__ = @as(c_int, 1);
//pub const __RDSEED__ = @as(c_int, 1);
//pub const __ADX__ = @as(c_int, 1);
//pub const __MOVBE__ = @as(c_int, 1);
//pub const __FMA__ = @as(c_int, 1);
//pub const __F16C__ = @as(c_int, 1);
//pub const __GFNI__ = @as(c_int, 1);
//pub const __SHA__ = @as(c_int, 1);
//pub const __FXSR__ = @as(c_int, 1);
//pub const __XSAVE__ = @as(c_int, 1);
//pub const __XSAVEOPT__ = @as(c_int, 1);
//pub const __XSAVEC__ = @as(c_int, 1);
//pub const __XSAVES__ = @as(c_int, 1);
//pub const __CLFLUSHOPT__ = @as(c_int, 1);
//pub const __CLWB__ = @as(c_int, 1);
//pub const __SHSTK__ = @as(c_int, 1);
//pub const __RDPID__ = @as(c_int, 1);
//pub const __WAITPKG__ = @as(c_int, 1);
//pub const __MOVDIRI__ = @as(c_int, 1);
//pub const __MOVDIR64B__ = @as(c_int, 1);
//pub const __PTWRITE__ = @as(c_int, 1);
//pub const __INVPCID__ = @as(c_int, 1);
//pub const __AVX2__ = @as(c_int, 1);
//pub const __AVX__ = @as(c_int, 1);
//pub const __SSE4_2__ = @as(c_int, 1);
//pub const __SSE4_1__ = @as(c_int, 1);
//pub const __SSSE3__ = @as(c_int, 1);
//pub const __SSE3__ = @as(c_int, 1);
//pub const __SSE2__ = @as(c_int, 1);
//pub const __SSE2_MATH__ = @as(c_int, 1);
//pub const __SSE__ = @as(c_int, 1);
//pub const __SSE_MATH__ = @as(c_int, 1);
//pub const __MMX__ = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
//pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
//pub const _WIN32 = @as(c_int, 1);
//pub const _WIN64 = @as(c_int, 1);
//pub const WIN32 = @as(c_int, 1);
//pub const __WIN32 = @as(c_int, 1);
//pub const __WIN32__ = @as(c_int, 1);
//pub const WINNT = @as(c_int, 1);
//pub const __WINNT = @as(c_int, 1);
//pub const __WINNT__ = @as(c_int, 1);
//pub const WIN64 = @as(c_int, 1);
//pub const __WIN64 = @as(c_int, 1);
//pub const __WIN64__ = @as(c_int, 1);
//pub const __MINGW64__ = @as(c_int, 1);
//pub const __MSVCRT__ = @as(c_int, 1);
//pub const __MINGW32__ = @as(c_int, 1);
//pub const __declspec = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// (no file):428:9
//pub const _cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):429:9
//pub const __cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):430:9
//pub const _stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):431:9
//pub const __stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):432:9
//pub const _fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):433:9
//pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):434:9
//pub const _thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):435:9
//pub const __thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):436:9
//pub const _pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):437:9
//pub const __pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):438:9
//pub const __STDC__ = @as(c_int, 1);
//pub const __STDC_HOSTED__ = @as(c_int, 1);
//pub const __STDC_VERSION__ = @as(c_long, 201710);
//pub const __STDC_UTF_16__ = @as(c_int, 1);
//pub const __STDC_UTF_32__ = @as(c_int, 1);
//pub const _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_PSTL_CPU_BACKEND_SERIAL = @as(c_int, 1);
//pub const _LIBCPP_ABI_VERSION = @as(c_int, 1);
//pub const _LIBCPP_ABI_NAMESPACE = @compileError("unable to translate macro: undefined identifier `__1`");
//// (no file):450:9
//pub const _LIBCPP_HARDENING_MODE = @compileError("unable to translate macro: undefined identifier `_LIBCPP_HARDENING_MODE_DEBUG`");
//// (no file):451:9
//pub const __MSVCRT_VERSION__ = @as(c_int, 0xE00);
//pub const _WIN32_WINNT = @as(c_int, 0x0a00);
//pub const _DEBUG = @as(c_int, 1);
//pub const SDL_hints_h_ = "";
pub const s_h_ = "";
//pub const SDL_error_h_ = "";
pub const error_h_ = "";
//pub const SDL_stdinc_h_ = "";
pub const stdinc_h_ = "";
//pub const SDL_platform_defines_h_ = "";
pub const platform_defines_h_ = "";
//pub const SDL_PLATFORM_WINDOWS = @as(c_int, 1);
//pub const HAVE_WINAPIFAMILY_H = @as(c_int, 0);
//pub const WINAPI_FAMILY_WINRT = @as(c_int, 0);
//pub const SDL_WINAPI_FAMILY_PHONE = @as(c_int, 0);
//pub const SDL_PLATFORM_WIN32 = @as(c_int, 1);
//pub const _LIBCPP_INTTYPES_H = "";
//pub const _LIBCPP___CONFIG = "";
//pub const _LIBCPP_COMPILER_CLANG_BASED = "";
//pub const _LIBCPP_CLANG_VER = (__clang_major__ * @as(c_int, 100)) + __clang_minor__;
//pub const __CLANG_INTTYPES_H = "";
//pub const _INTTYPES_H_ = "";
//pub const _INC_CRTDEFS = "";
//pub const _INC_CORECRT = "";
//pub const _INC__MINGW_H = "";
//pub const _INC_CRTDEFS_MACRO = "";
//pub const __STRINGIFY = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:10:9
//pub inline fn __MINGW64_STRINGIFY(x: anytype) @TypeOf(__STRINGIFY(x)) {
//    _ = &x;
//    return __STRINGIFY(x);
//}
//pub const __MINGW64_VERSION_MAJOR = @as(c_int, 12);
//pub const __MINGW64_VERSION_MINOR = @as(c_int, 0);
//pub const __MINGW64_VERSION_BUGFIX = @as(c_int, 0);
//pub const __MINGW64_VERSION_RC = @as(c_int, 0);
//pub const __MINGW64_VERSION_STR = __MINGW64_STRINGIFY(__MINGW64_VERSION_MAJOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_MINOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_BUGFIX);
//pub const __MINGW64_VERSION_STATE = "alpha";
//pub const __MINGW32_MAJOR_VERSION = @as(c_int, 3);
//pub const __MINGW32_MINOR_VERSION = @as(c_int, 11);
//pub const _M_AMD64 = @as(c_int, 100);
//pub const _M_X64 = @as(c_int, 100);
//pub const @"_" = @as(c_int, 1);
//pub const __MINGW_USE_UNDERSCORE_PREFIX = @as(c_int, 0);
//pub const __MINGW_IMP_SYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:119:11
//pub const __MINGW_IMP_LSYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:120:11
//pub inline fn __MINGW_USYMBOL(sym: anytype) @TypeOf(sym) {
//    _ = &sym;
//    return sym;
//}
//pub const __MINGW_LSYMBOL = @compileError("unable to translate C expr: unexpected token '##'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:122:11
//pub const __MINGW_ASM_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:130:9
//pub const __MINGW_ASM_CRT_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:131:9
//pub const __MINGW_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:163:13
//pub const __C89_NAMELESS = __MINGW_EXTENSION;
//pub const __C89_NAMELESSSTRUCTNAME = "";
//pub const __C89_NAMELESSSTRUCTNAME1 = "";
//pub const __C89_NAMELESSSTRUCTNAME2 = "";
//pub const __C89_NAMELESSSTRUCTNAME3 = "";
//pub const __C89_NAMELESSSTRUCTNAME4 = "";
//pub const __C89_NAMELESSSTRUCTNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME = "";
//pub const __C89_NAMELESSUNIONNAME1 = "";
//pub const __C89_NAMELESSUNIONNAME2 = "";
//pub const __C89_NAMELESSUNIONNAME3 = "";
//pub const __C89_NAMELESSUNIONNAME4 = "";
//pub const __C89_NAMELESSUNIONNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME6 = "";
//pub const __C89_NAMELESSUNIONNAME7 = "";
//pub const __C89_NAMELESSUNIONNAME8 = "";
//pub const __GNU_EXTENSION = __MINGW_EXTENSION;
//pub const __MINGW_HAVE_ANSI_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_ANSI_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_POISON_NAME = @compileError("unable to translate macro: undefined identifier `_layout_has_not_been_verified_and_its_declaration_is_most_likely_incorrect`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:203:11
//pub const __MSABI_LONG = @import("std").zig.c_translation.Macros.L_SUFFIX;
//pub const __MINGW_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
//pub inline fn __MINGW_GNUC_PREREQ(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
//    _ = &major;
//    _ = &minor;
//    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
//}
//pub inline fn __MINGW_MSC_PREREQ(major: anytype, minor: anytype) @TypeOf(@as(c_int, 0)) {
//    _ = &major;
//    _ = &minor;
//    return @as(c_int, 0);
//}
//pub const __MINGW_ATTRIB_DEPRECATED_STR = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:247:11
//pub const __MINGW_SEC_WARN_STR = "This function or variable may be unsafe, use _CRT_SECURE_NO_WARNINGS to disable deprecation";
//pub const __MINGW_MSVC2005_DEPREC_STR = "This POSIX function is deprecated beginning in Visual C++ 2005, use _CRT_NONSTDC_NO_DEPRECATE to disable deprecation";
//pub const __MINGW_ATTRIB_DEPRECATED_MSVC2005 = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_MSVC2005_DEPREC_STR);
//pub const __MINGW_ATTRIB_DEPRECATED_SEC_WARN = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_SEC_WARN_STR);
//pub const __MINGW_MS_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:270:9
//pub const __MINGW_MS_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:273:9
//pub const __MINGW_GNU_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:276:9
//pub const __MINGW_GNU_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:279:9
//pub const __mingw_ovr = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:289:11
//pub const __mingw_static_ovr = __mingw_ovr;
//pub const __mingw_attribute_artificial = @compileError("unable to translate macro: undefined identifier `__artificial__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:298:11
//pub const __MINGW_SELECTANY = @compileError("unable to translate macro: undefined identifier `__selectany__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:304:9
//pub const __MINGW_FORTIFY_LEVEL = @as(c_int, 0);
//pub const __mingw_bos_ovr = __mingw_ovr;
//pub const __MINGW_FORTIFY_VA_ARG = @as(c_int, 0);
//pub const _INC_MINGW_SECAPI = "";
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = @as(c_int, 0);
//pub const __MINGW_CRT_NAME_CONCAT2 = @compileError("unable to translate macro: undefined identifier `_s`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:41:9
//pub const __CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY_0_3_ = @compileError("unable to translate C expr: unexpected token ';'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:69:9
//pub const __LONG32 = c_long;
//pub const __MINGW_IMPORT = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:44:12
//pub const __USE_CRTIMP = @as(c_int, 1);
//pub const _CRTIMP = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:52:15
//pub const __DECLSPEC_SUPPORTED = "";
//pub const USE___UUIDOF = @as(c_int, 0);
//pub const _inline = @compileError("unable to translate C expr: unexpected token '__inline'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:74:9
//pub const __CRT_INLINE = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:83:11
//pub const __MINGW_INTRIN_INLINE = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:90:9
//pub const __CRT__NO_INLINE = @as(c_int, 1);
//pub const __UNUSED_PARAM = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:104:11
//pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:119:10
//pub const __MINGW_ATTRIB_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:135:9
//pub const __MINGW_ATTRIB_CONST = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:136:9
//pub const __MINGW_ATTRIB_MALLOC = @compileError("unable to translate macro: undefined identifier `__malloc__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:146:9
//pub const __MINGW_ATTRIB_PURE = @compileError("unable to translate macro: undefined identifier `__pure__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:147:9
//pub const __MINGW_ATTRIB_NONNULL = @compileError("unable to translate macro: undefined identifier `__nonnull__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:160:9
//pub const __MINGW_ATTRIB_UNUSED = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:166:9
//pub const __MINGW_ATTRIB_USED = @compileError("unable to translate macro: undefined identifier `__used__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:172:9
//pub const __MINGW_ATTRIB_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:173:9
//pub const __MINGW_ATTRIB_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:175:9
//pub const __MINGW_NOTHROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:190:9
//pub const __MINGW_ATTRIB_NO_OPTIMIZE = "";
//pub const __MINGW_PRAGMA_PARAM = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:208:9
//pub const __MINGW_BROKEN_INTERFACE = @compileError("unable to translate macro: undefined identifier `message`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:211:9
//pub const _UCRT = "";
//pub const _INT128_DEFINED = "";
//pub const __int8 = u8;
//pub const __int16 = c_short;
//pub const __int32 = c_int;
//pub const __int64 = c_longlong;
//pub const __ptr32 = "";
//pub const __ptr64 = "";
//pub const __unaligned = "";
//pub const __w64 = "";
//pub const __forceinline = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:266:9
//pub const __nothrow = "";
//pub const _INC_VADEFS = "";
//pub const MINGW_SDK_INIT = "";
//pub const MINGW_HAS_SECURE_API = @as(c_int, 1);
//pub const __STDC_SECURE_LIB__ = @as(c_long, 200411);
//pub const __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;
//pub const MINGW_DDK_H = "";
//pub const MINGW_HAS_DDK_H = @as(c_int, 1);
//pub const _CRT_PACKING = @as(c_int, 8);
//pub const __GNUC_VA_LIST = "";
//pub const _VA_LIST_DEFINED = "";
//pub inline fn _ADDRESSOF(v: anytype) @TypeOf(&v) {
//    _ = &v;
//    return &v;
//}
//pub const _crt_va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:48:9
//pub const _crt_va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:49:9
//pub const _crt_va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:50:9
//pub const _crt_va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:51:9
//pub const __CRT_STRINGIZE = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:285:9
//pub inline fn _CRT_STRINGIZE(_Value: anytype) @TypeOf(__CRT_STRINGIZE(_Value)) {
//    _ = &_Value;
//    return __CRT_STRINGIZE(_Value);
//}
//pub const __CRT_WIDE = @compileError("unable to translate macro: undefined identifier `L`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:290:9
//pub inline fn _CRT_WIDE(_String: anytype) @TypeOf(__CRT_WIDE(_String)) {
//    _ = &_String;
//    return __CRT_WIDE(_String);
//}
//pub const _W64 = "";
//pub const _CRTIMP_NOIA64 = _CRTIMP;
//pub const _CRTIMP2 = _CRTIMP;
//pub const _CRTIMP_ALTERNATIVE = _CRTIMP;
//pub const _CRT_ALTERNATIVE_IMPORTED = "";
//pub const _MRTIMP2 = _CRTIMP;
//pub const _DLL = "";
//pub const _MT = "";
//pub const _MCRTIMP = _CRTIMP;
//pub const _CRTIMP_PURE = _CRTIMP;
//pub const _PGLOBAL = "";
//pub const _AGLOBAL = "";
//pub const _SECURECRT_FILL_BUFFER_PATTERN = @as(c_int, 0xFD);
//pub const _CRT_DEPRECATE_TEXT = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:349:9
//pub const _CRT_INSECURE_DEPRECATE_MEMORY = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:352:9
//pub const _CRT_INSECURE_DEPRECATE_GLOBALS = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:356:9
//pub const _CRT_MANAGED_HEAP_DEPRECATE = "";
//pub const _CRT_OBSOLETE = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:364:9
//pub const _CONST_RETURN = "";
//pub const UNALIGNED = "";
//pub const _CRT_ALIGN = @compileError("unable to translate macro: undefined identifier `__aligned__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:391:9
//pub const __CRTDECL = __cdecl;
//pub const _ARGMAX = @as(c_int, 100);
//pub const _TRUNCATE = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub inline fn _CRT_UNUSED(x: anytype) anyopaque {
//    _ = &x;
//    return @import("std").zig.c_translation.cast(anyopaque, x);
//}
//pub const __USE_MINGW_ANSI_STDIO = @as(c_int, 0);
//pub const _CRT_glob = @compileError("unable to translate macro: undefined identifier `_dowildcard`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:455:9
//pub const __ANONYMOUS_DEFINED = "";
//pub const _ANONYMOUS_UNION = __MINGW_EXTENSION;
//pub const _ANONYMOUS_STRUCT = __MINGW_EXTENSION;
//pub const _UNION_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:475:9
//pub const _STRUCT_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:476:9
//pub const DUMMYUNIONNAME = "";
//pub const DUMMYUNIONNAME1 = "";
//pub const DUMMYUNIONNAME2 = "";
//pub const DUMMYUNIONNAME3 = "";
//pub const DUMMYUNIONNAME4 = "";
//pub const DUMMYUNIONNAME5 = "";
//pub const DUMMYUNIONNAME6 = "";
//pub const DUMMYUNIONNAME7 = "";
//pub const DUMMYUNIONNAME8 = "";
//pub const DUMMYUNIONNAME9 = "";
//pub const DUMMYSTRUCTNAME = "";
//pub const DUMMYSTRUCTNAME1 = "";
//pub const DUMMYSTRUCTNAME2 = "";
//pub const DUMMYSTRUCTNAME3 = "";
//pub const DUMMYSTRUCTNAME4 = "";
//pub const DUMMYSTRUCTNAME5 = "";
//pub const __CRT_UUID_DECL = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:563:9
//pub const __MINGW_DEBUGBREAK_IMPL = !(__has_builtin(__debugbreak) != 0);
//pub const __MINGW_FASTFAIL_IMPL = !(__has_builtin(__fastfail) != 0);
//pub const __MINGW_PREFETCH_IMPL = @compileError("unable to translate macro: undefined identifier `__prefetch`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:620:9
//pub const _CRTNOALIAS = "";
//pub const _CRTRESTRICT = "";
//pub const _SIZE_T_DEFINED = "";
//pub const _SSIZE_T_DEFINED = "";
//pub const _RSIZE_T_DEFINED = "";
//pub const _INTPTR_T_DEFINED = "";
//pub const __intptr_t_defined = "";
//pub const _UINTPTR_T_DEFINED = "";
//pub const __uintptr_t_defined = "";
//pub const _PTRDIFF_T_DEFINED = "";
//pub const _PTRDIFF_T_ = "";
//pub const _WCHAR_T_DEFINED = "";
//pub const _WCTYPE_T_DEFINED = "";
//pub const _WINT_T = "";
//pub const _ERRCODE_DEFINED = "";
//pub const _TIME32_T_DEFINED = "";
//pub const _TIME64_T_DEFINED = "";
//pub const _TIME_T_DEFINED = "";
//pub const _CRT_SECURE_CPP_NOTHROW = @compileError("unable to translate macro: undefined identifier `throw`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:143:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:262:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:263:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:264:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:265:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_4 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:266:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:267:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:268:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:269:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_2_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:270:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:271:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:272:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_SPLITPATH = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:273:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:277:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:279:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:281:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:283:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:285:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:422:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:423:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:424:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:425:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:426:9
//pub const _TAGLC_ID_DEFINED = "";
//pub const _THREADLOCALEINFO = "";
//pub const __crt_typefix = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:486:9
//pub const _CRT_USE_WINAPI_FAMILY_DESKTOP_APP = "";
//pub const _LIBCPP_STDINT_H = "";
//pub const __CLANG_STDINT_H = "";
//pub const _STDINT_H = "";
//pub const __need_wint_t = "";
//pub const __need_wchar_t = "";
//pub const _WCHAR_T = "";
//pub const _LIBCPP_STDDEF_H = "";
//pub const INT8_MIN = -@as(c_int, 128);
//pub const INT16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
//pub const INT32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
//pub const INT64_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
//pub const INT8_MAX = @as(c_int, 127);
//pub const INT16_MAX = @as(c_int, 32767);
//pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
//pub const UINT8_MAX = @as(c_int, 255);
//pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffffffff, .hex);
//pub const UINT64_MAX = @as(c_ulonglong, 0xffffffffffffffff);
//pub const INT_LEAST8_MIN = INT8_MIN;
//pub const INT_LEAST16_MIN = INT16_MIN;
//pub const INT_LEAST32_MIN = INT32_MIN;
//pub const INT_LEAST64_MIN = INT64_MIN;
//pub const INT_LEAST8_MAX = INT8_MAX;
//pub const INT_LEAST16_MAX = INT16_MAX;
//pub const INT_LEAST32_MAX = INT32_MAX;
//pub const INT_LEAST64_MAX = INT64_MAX;
//pub const UINT_LEAST8_MAX = UINT8_MAX;
//pub const UINT_LEAST16_MAX = UINT16_MAX;
//pub const UINT_LEAST32_MAX = UINT32_MAX;
//pub const UINT_LEAST64_MAX = UINT64_MAX;
//pub const INT_FAST8_MIN = INT8_MIN;
//pub const INT_FAST16_MIN = INT16_MIN;
//pub const INT_FAST32_MIN = INT32_MIN;
//pub const INT_FAST64_MIN = INT64_MIN;
//pub const INT_FAST8_MAX = INT8_MAX;
//pub const INT_FAST16_MAX = INT16_MAX;
//pub const INT_FAST32_MAX = INT32_MAX;
//pub const INT_FAST64_MAX = INT64_MAX;
//pub const UINT_FAST8_MAX = UINT8_MAX;
//pub const UINT_FAST16_MAX = UINT16_MAX;
//pub const UINT_FAST32_MAX = UINT32_MAX;
//pub const UINT_FAST64_MAX = UINT64_MAX;
//pub const INTPTR_MIN = INT64_MIN;
//pub const INTPTR_MAX = INT64_MAX;
//pub const UINTPTR_MAX = UINT64_MAX;
//pub const INTMAX_MIN = INT64_MIN;
//pub const INTMAX_MAX = INT64_MAX;
//pub const UINTMAX_MAX = UINT64_MAX;
//pub const PTRDIFF_MIN = INT64_MIN;
//pub const PTRDIFF_MAX = INT64_MAX;
//pub const SIG_ATOMIC_MIN = INT32_MIN;
//pub const SIG_ATOMIC_MAX = INT32_MAX;
//pub const SIZE_MAX = UINT64_MAX;
//pub const WCHAR_MIN = @as(c_uint, 0);
//pub const WCHAR_MAX = @as(c_uint, 0xffff);
//pub const WINT_MIN = @as(c_uint, 0);
//pub const WINT_MAX = @as(c_uint, 0xffff);
//pub inline fn INT8_C(val: anytype) @TypeOf((INT_LEAST8_MAX - INT_LEAST8_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST8_MAX - INT_LEAST8_MAX) + val;
//}
//pub inline fn INT16_C(val: anytype) @TypeOf((INT_LEAST16_MAX - INT_LEAST16_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST16_MAX - INT_LEAST16_MAX) + val;
//}
//pub inline fn INT32_C(val: anytype) @TypeOf((INT_LEAST32_MAX - INT_LEAST32_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST32_MAX - INT_LEAST32_MAX) + val;
//}
//pub const INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub inline fn UINT8_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub inline fn UINT16_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub const UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
//pub const UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const INTMAX_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub const UINTMAX_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const PRId64 = "lld";
//pub const PRIi64 = "lli";
//pub const PRIo64 = "llo";
//pub const PRIu64 = "llu";
//pub const PRIx64 = "llx";
//pub const PRIX64 = "llX";
//pub const PRId8 = "d";
//pub const PRId16 = "d";
//pub const PRId32 = "d";
//pub const PRIdLEAST8 = "d";
//pub const PRIdLEAST16 = "d";
//pub const PRIdLEAST32 = "d";
//pub const PRIdLEAST64 = PRId64;
//pub const PRIdFAST8 = "d";
//pub const PRIdFAST16 = "d";
//pub const PRIdFAST32 = "d";
//pub const PRIdFAST64 = PRId64;
//pub const PRIdMAX = PRId64;
//pub const PRIi8 = "i";
//pub const PRIi16 = "i";
//pub const PRIi32 = "i";
//pub const PRIiLEAST8 = "i";
//pub const PRIiLEAST16 = "i";
//pub const PRIiLEAST32 = "i";
//pub const PRIiLEAST64 = PRIi64;
//pub const PRIiFAST8 = "i";
//pub const PRIiFAST16 = "i";
//pub const PRIiFAST32 = "i";
//pub const PRIiFAST64 = PRIi64;
//pub const PRIiMAX = PRIi64;
//pub const PRIo8 = "o";
//pub const PRIo16 = "o";
//pub const PRIo32 = "o";
//pub const PRIoLEAST8 = "o";
//pub const PRIoLEAST16 = "o";
//pub const PRIoLEAST32 = "o";
//pub const PRIoLEAST64 = PRIo64;
//pub const PRIoFAST8 = "o";
//pub const PRIoFAST16 = "o";
//pub const PRIoFAST32 = "o";
//pub const PRIoFAST64 = PRIo64;
//pub const PRIoMAX = PRIo64;
//pub const PRIu8 = "u";
//pub const PRIu16 = "u";
//pub const PRIu32 = "u";
//pub const PRIuLEAST8 = "u";
//pub const PRIuLEAST16 = "u";
//pub const PRIuLEAST32 = "u";
//pub const PRIuLEAST64 = PRIu64;
//pub const PRIuFAST8 = "u";
//pub const PRIuFAST16 = "u";
//pub const PRIuFAST32 = "u";
//pub const PRIuFAST64 = PRIu64;
//pub const PRIuMAX = PRIu64;
//pub const PRIx8 = "x";
//pub const PRIx16 = "x";
//pub const PRIx32 = "x";
//pub const PRIxLEAST8 = "x";
//pub const PRIxLEAST16 = "x";
//pub const PRIxLEAST32 = "x";
//pub const PRIxLEAST64 = PRIx64;
//pub const PRIxFAST8 = "x";
//pub const PRIxFAST16 = "x";
//pub const PRIxFAST32 = "x";
//pub const PRIxFAST64 = PRIx64;
//pub const PRIxMAX = PRIx64;
//pub const PRIX8 = "X";
//pub const PRIX16 = "X";
//pub const PRIX32 = "X";
//pub const PRIXLEAST8 = "X";
//pub const PRIXLEAST16 = "X";
//pub const PRIXLEAST32 = "X";
//pub const PRIXLEAST64 = PRIX64;
//pub const PRIXFAST8 = "X";
//pub const PRIXFAST16 = "X";
//pub const PRIXFAST32 = "X";
//pub const PRIXFAST64 = PRIX64;
//pub const PRIXMAX = PRIX64;
//pub const SCNd16 = "hd";
//pub const SCNd32 = "d";
//pub const SCNd64 = PRId64;
//pub const SCNdLEAST16 = "hd";
//pub const SCNdLEAST32 = "d";
//pub const SCNdLEAST64 = PRId64;
//pub const SCNdFAST16 = "hd";
//pub const SCNdFAST32 = "d";
//pub const SCNdFAST64 = PRId64;
//pub const SCNdMAX = PRId64;
//pub const SCNi16 = "hi";
//pub const SCNi32 = "i";
//pub const SCNi64 = PRIi64;
//pub const SCNiLEAST16 = "hi";
//pub const SCNiLEAST32 = "i";
//pub const SCNiLEAST64 = PRIi64;
//pub const SCNiFAST16 = "hi";
//pub const SCNiFAST32 = "i";
//pub const SCNiFAST64 = PRIi64;
//pub const SCNiMAX = PRIi64;
//pub const SCNo16 = "ho";
//pub const SCNo32 = "o";
//pub const SCNo64 = PRIo64;
//pub const SCNoLEAST16 = "ho";
//pub const SCNoLEAST32 = "o";
//pub const SCNoLEAST64 = PRIo64;
//pub const SCNoFAST16 = "ho";
//pub const SCNoFAST32 = "o";
//pub const SCNoFAST64 = PRIo64;
//pub const SCNoMAX = PRIo64;
//pub const SCNx16 = "hx";
//pub const SCNx32 = "x";
//pub const SCNx64 = PRIx64;
//pub const SCNxLEAST16 = "hx";
//pub const SCNxLEAST32 = "x";
//pub const SCNxLEAST64 = PRIx64;
//pub const SCNxFAST16 = "hx";
//pub const SCNxFAST32 = "x";
//pub const SCNxFAST64 = PRIx64;
//pub const SCNxMAX = PRIx64;
//pub const SCNu16 = "hu";
//pub const SCNu32 = "u";
//pub const SCNu64 = PRIu64;
//pub const SCNuLEAST16 = "hu";
//pub const SCNuLEAST32 = "u";
//pub const SCNuLEAST64 = PRIu64;
//pub const SCNuFAST16 = "hu";
//pub const SCNuFAST32 = "u";
//pub const SCNuFAST64 = PRIu64;
//pub const SCNuMAX = PRIu64;
//pub const PRIdPTR = PRId64;
//pub const PRIiPTR = PRIi64;
//pub const PRIoPTR = PRIo64;
//pub const PRIuPTR = PRIu64;
//pub const PRIxPTR = PRIx64;
//pub const PRIXPTR = PRIX64;
//pub const SCNdPTR = PRId64;
//pub const SCNiPTR = PRIi64;
//pub const SCNoPTR = PRIo64;
//pub const SCNxPTR = PRIx64;
//pub const SCNuPTR = PRIu64;
//pub const SCNd8 = "hhd";
//pub const SCNdLEAST8 = "hhd";
//pub const SCNdFAST8 = "hhd";
//pub const SCNi8 = "hhi";
//pub const SCNiLEAST8 = "hhi";
//pub const SCNiFAST8 = "hhi";
//pub const SCNo8 = "hho";
//pub const SCNoLEAST8 = "hho";
//pub const SCNoFAST8 = "hho";
//pub const SCNx8 = "hhx";
//pub const SCNxLEAST8 = "hhx";
//pub const SCNxFAST8 = "hhx";
//pub const SCNu8 = "hhu";
//pub const SCNuLEAST8 = "hhu";
//pub const SCNuFAST8 = "hhu";
//pub const __STDARG_H = "";
//pub const __need___va_list = "";
//pub const __need_va_list = "";
//pub const __need_va_arg = "";
//pub const __need___va_copy = "";
//pub const __need_va_copy = "";
//pub const _VA_LIST = "";
//pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:17:9
//pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:19:9
//pub const va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:20:9
//pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg___va_copy.h:11:9
//pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_copy.h:11:9
//pub const _LIBCPP_STDBOOL_H = "";
//pub const __STDBOOL_H = "";
//pub const __bool_true_false_are_defined = @as(c_int, 1);
//pub const @"bool" = bool;
//pub const @"true" = @as(c_int, 1);
//pub const @"false" = @as(c_int, 0);
//pub const _LIBCPP_STRING_H = "";
//pub const _INC_STRING = "";
//pub const _SECIMP = @compileError("unable to translate macro: undefined identifier `dllimport`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/string.h:16:9
//pub const _NLSCMP_DEFINED = "";
//pub const _NLSCMPERROR = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
//pub const _WConst_return = "";
//pub const _CRT_MEMORY_DEFINED = "";
//pub const _WSTRING_DEFINED = "";
//pub const wcswcs = wcsstr;
//pub const _INC_STRING_S = "";
//pub const _WSTRING_S_DEFINED = "";
//pub const _LIBCPP_WCHAR_H = "";
//pub const __STDDEF_H = "";
//pub const __need_ptrdiff_t = "";
//pub const __need_size_t = "";
//pub const __need_NULL = "";
//pub const __need_max_align_t = "";
//pub const __need_offsetof = "";
//pub const _PTRDIFF_T = "";
//pub const _SIZE_T = "";
//pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
//pub const offsetof = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stddef_offsetof.h:16:9
//pub const _INC_WCHAR = "";
//pub const _STDIO_CONFIG_DEFINED = "";
//pub const _CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_PRINTF_STANDARD_SNPRINTF_BEHAVIOR = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0008);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_THREE_DIGIT_EXPONENTS = @as(c_ulonglong, 0x0010);
//pub const _CRT_INTERNAL_SCANF_SECURECRT = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_SCANF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_LOCAL_PRINTF_OPTIONS = _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS;
//pub const _CRT_INTERNAL_LOCAL_SCANF_OPTIONS = _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS;
//pub const _INC_CORECRT_WSTDLIB = "";
//pub const WEOF = @import("std").zig.c_translation.cast(wint_t, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const _FILE_DEFINED = "";
//pub const _iob = __iob_func();
//pub const stdin = __acrt_iob_func(@as(c_int, 0));
//pub const stdout = __acrt_iob_func(@as(c_int, 1));
//pub const stderr = __acrt_iob_func(@as(c_int, 2));
//pub const _STDSTREAM_DEFINED = "";
//pub const _FSIZE_T_DEFINED = "";
//pub const _wfinddata_t = _wfinddata64i32_t;
//pub const _wfinddatai64_t = _wfinddata64_t;
//pub const _wfindfirst = _wfindfirst64i32;
//pub const _wfindnext = _wfindnext64i32;
//pub const _wfindfirsti64 = _wfindfirst64;
//pub const _wfindnexti64 = _wfindnext64;
//pub const _WFINDDATA_T_DEFINED = "";
//pub const _CRT_CTYPEDATA_DEFINED = "";
//pub const __PCTYPE_FUNC = __pctype_func();
//pub const _pctype = __pctype_func();
//pub const _CRT_WCTYPEDATA_DEFINED = "";
//pub const _wctype = __MINGW_IMP_SYMBOL(_wctype).*;
//pub inline fn __pwctype_func() @TypeOf(__MINGW_IMP_SYMBOL(_pwctype).*) {
//    return __MINGW_IMP_SYMBOL(_pwctype).*;
//}
//pub const _pwctype = __MINGW_IMP_SYMBOL(_pwctype).*;
//pub const _UPPER = @as(c_int, 0x1);
//pub const _LOWER = @as(c_int, 0x2);
//pub const _DIGIT = @as(c_int, 0x4);
//pub const _SPACE = @as(c_int, 0x8);
//pub const _PUNCT = @as(c_int, 0x10);
//pub const _CONTROL = @as(c_int, 0x20);
//pub const _BLANK = @as(c_int, 0x40);
//pub const _HEX = @as(c_int, 0x80);
//pub const _LEADBYTE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x8000, .hex);
//pub const _ALPHA = (@as(c_int, 0x0100) | _UPPER) | _LOWER;
//pub const _WCTYPE_DEFINED = "";
//pub const _WDIRECT_DEFINED = "";
//pub const _WIO_DEFINED = "";
//pub const _WLOCALE_DEFINED = "";
//pub const _WEXEC_DEFINED = "";
//pub const _WSPAWN_DEFINED = "";
//pub const _CRT_WSYSTEM_DEFINED = "";
//pub const _WCTYPE_INLINE_DEFINED = "";
//pub const _INO_T_DEFINED = "";
//pub const _DEV_T_DEFINED = "";
//pub const _OFF_T_DEFINED = "";
//pub const _OFF_T_ = "";
//pub const _OFF64_T_DEFINED = "";
//pub const _FILE_OFFSET_BITS_SET_OFFT = "";
//pub const _fstat = @compileError("unable to translate macro: undefined identifier `_fstat64i32`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:17:9
//pub const _fstati64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:18:9
//pub const _stat = _stat64i32;
//pub const _stati64 = _stat64;
//pub const _wstat = _wstat64i32;
//pub const _wstati64 = _wstat64;
//pub const __stat64 = _stat64;
//pub const stat64 = _stat64;
//pub const fstat64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:99:9
//pub const _STAT_DEFINED = "";
//pub const _WSTAT_DEFINED = "";
//pub const _WCONIO_DEFINED = "";
//pub const _WSTDIO_DEFINED = "";
//pub const _INC_SWPRINTF_INL = "";
//pub const _CRT_WPERROR_DEFINED = "";
//pub const wpopen = _wpopen;
//pub inline fn _putwc_nolock(_c: anytype, _stm: anytype) @TypeOf(_fputwc_nolock(_c, _stm)) {
//    _ = &_c;
//    _ = &_stm;
//    return _fputwc_nolock(_c, _stm);
//}
//pub inline fn _getwc_nolock(_c: anytype) @TypeOf(_fgetwc_nolock(_c)) {
//    _ = &_c;
//    return _fgetwc_nolock(_c);
//}
//pub const _WSTDLIB_DEFINED = "";
//pub const _WSTDLIBP_DEFINED = "";
//pub const _TM_DEFINED = "";
//pub const _WTIME_DEFINED = "";
//pub const _INC_WTIME_INL = "";
//pub const _INC_WTIME_S_INL = "";
//pub const __MINGW_MBWC_CONVERT_DEFINED = "";
//pub const _INC_WCHAR_S = "";
//pub const _WIO_S_DEFINED = "";
//pub const _WCONIO_S_DEFINED = "";
//pub const _WSTDIO_S_DEFINED = "";
//pub const _WTIME_S_DEFINED = "";
//pub const alloca = @compileError("unable to translate macro: undefined identifier `__builtin_alloca`");
//// ./include/SDL3/SDL_stdinc.h:59:12
//pub const SDL_SIZE_MAX = SIZE_MAX;
//pub inline fn SDL_HAS_BUILTIN(x: anytype) @TypeOf(__has_builtin(x)) {
//    _ = &x;
//    return __has_builtin(x);
//}
//pub const SDL_arraysize = @compileError("unable to translate C expr: expected ')' instead got '['");
//// ./include/SDL3/SDL_stdinc.h:105:9
//pub const SDL_STRINGIFY_ARG = @compileError("unable to translate C expr: unexpected token '#'");
//// ./include/SDL3/SDL_stdinc.h:118:9
//pub const SDL_reinterpret_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_static_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_const_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub inline fn SDL_FOURCC(A: anytype, B: anytype, C: anytype, D: anytype) @TypeOf((((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24))) {
//    _ = &A;
//    _ = &B;
//    _ = &C;
//    _ = &D;
//    return (((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24));
//}
//pub inline fn SDL_SINT64_C(c: anytype) @TypeOf(INT64_C(c)) {
//    _ = &c;
//    return INT64_C(c);
//}
//pub inline fn SDL_UINT64_C(c: anytype) @TypeOf(UINT64_C(c)) {
//    _ = &c;
//    return UINT64_C(c);
//}
//pub const SDL_FALSE = @"false";
//pub const SDL_TRUE = @"true";
//pub const SDL_MAX_SINT8 = @import("std").zig.c_translation.cast(Sint8, @as(c_int, 0x7F));
//pub const SDL_MIN_SINT8 = @import("std").zig.c_translation.cast(Sint8, ~@as(c_int, 0x7F));
//pub const SDL_MAX_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0xFF));
//pub const SDL_MIN_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0x00));
//pub const SDL_MAX_SINT16 = @import("std").zig.c_translation.cast(Sint16, @as(c_int, 0x7FFF));
//pub const SDL_MIN_SINT16 = @import("std").zig.c_translation.cast(Sint16, ~@as(c_int, 0x7FFF));
//pub const SDL_MAX_UINT16 = @import("std").zig.c_translation.cast(Uint16, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const SDL_MIN_UINT16 = @import("std").zig.c_translation.cast(Uint16, @as(c_int, 0x0000));
//pub const SDL_MAX_SINT32 = @import("std").zig.c_translation.cast(Sint32, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MIN_SINT32 = @import("std").zig.c_translation.cast(Sint32, ~@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MAX_UINT32 = @import("std").zig.c_translation.cast(Uint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xFFFFFFFF, .hex));
//pub const SDL_MIN_UINT32 = @import("std").zig.c_translation.cast(Uint32, @as(c_int, 0x00000000));
//pub const SDL_MAX_SINT64 = SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_SINT64 = ~SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MAX_UINT64 = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_UINT64 = SDL_UINT64_C(@as(c_int, 0x0000000000000000));
//pub const SDL_MAX_TIME = SDL_MAX_SINT64;
//pub const SDL_MIN_TIME = SDL_MIN_SINT64;
//pub const SDL_FLT_EPSILON = @as(f32, 1.1920928955078125e-07);
//pub const SDL_PRIs64 = "I64d";
//pub const pris64 = "I64d";
//pub const SDL_PRIu64 = "I64u";
//pub const priu64 = "I64u";
//pub const SDL_PRIx64 = "I64x";
//pub const prix64 = "I64x";
//pub const SDL_PRIX64 = "I64X";
//pub const prix64 = "I64X";
//pub const SDL_PRIs32 = PRId32;
//pub const SDL_PRIu32 = PRIu32;
//pub const SDL_PRIx32 = PRIx32;
//pub const SDL_PRIX32 = PRIX32;
//pub const SDL_IN_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:526:9
//pub const SDL_INOUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:527:9
//pub const SDL_OUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:528:9
//pub const SDL_OUT_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:529:9
//pub const SDL_OUT_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:530:9
//pub const SDL_OUT_Z_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:531:9
//pub const SDL_PRINTF_FORMAT_STRING = "";
pub const printf_format_string = "";
//pub const SDL_SCANF_FORMAT_STRING = "";
pub const scanf_format_string = "";
//pub const SDL_PRINTF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:536:9
//pub const SDL_PRINTF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:537:9
//pub const SDL_SCANF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:538:9
//pub const SDL_SCANF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:539:9
//pub const SDL_WPRINTF_VARARG_FUNC = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:540:9
//pub const SDL_WPRINTF_VARARG_FUNCV = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:541:9
//pub const SDL_COMPILE_TIME_ASSERT = @compileError("unable to translate C expr: unexpected token '_Static_assert'");
//// ./include/SDL3/SDL_stdinc.h:561:9
//pub const SDL_begin_code_h = "";
//pub const SDL_DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// ./include/SDL3/SDL_begin_code.h:38:13
//pub const SDL_UNUSED = @compileError("unable to translate macro: undefined identifier `unused`");
//// ./include/SDL3/SDL_begin_code.h:48:13
//pub const SDL_DECLSPEC = "";
pub const declspec = "";
//pub const SDLCALL = "";
pub const call = "";
//pub const SDL_INLINE = @compileError("unable to translate C expr: unexpected token '__inline__'");
//// ./include/SDL3/SDL_begin_code.h:105:9
//pub const SDL_FORCE_INLINE = @compileError("unable to translate macro: undefined identifier `always_inline`");
//// ./include/SDL3/SDL_begin_code.h:126:9
//pub const SDL_NORETURN = @compileError("unable to translate macro: undefined identifier `noreturn`");
//// ./include/SDL3/SDL_begin_code.h:134:9
//pub const SDL_ANALYZER_NORETURN = @compileError("unable to translate macro: undefined identifier `analyzer_noreturn`");
//// ./include/SDL3/SDL_begin_code.h:144:9
//pub const SDL_HAS_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
//// ./include/SDL3/SDL_begin_code.h:169:9
//pub const SDL_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__fallthrough__`");
//// ./include/SDL3/SDL_begin_code.h:176:9
//pub const SDL_NODISCARD = @compileError("unable to translate macro: undefined identifier `warn_unused_result`");
//// ./include/SDL3/SDL_begin_code.h:189:9
//pub const SDL_MALLOC = @compileError("unable to translate macro: undefined identifier `malloc`");
//// ./include/SDL3/SDL_begin_code.h:199:9
//pub const SDL_ALLOC_SIZE = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:211:9
//pub const SDL_ALLOC_SIZE2 = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:221:9
//pub const SDL_INIT_INTERFACE = @compileError("unable to translate C expr: unexpected token 'do'");
//// ./include/SDL3/SDL_stdinc.h:658:9
//pub const SDL_stack_alloc = @compileError("unable to translate C expr: unexpected token ')'");
//// ./include/SDL3/SDL_stdinc.h:666:9
//pub const SDL_stack_free = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:667:9
//pub inline fn SDL_min(x: anytype, y: anytype) @TypeOf(if (x < y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x < y) x else y;
//}
//pub inline fn SDL_max(x: anytype, y: anytype) @TypeOf(if (x > y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x > y) x else y;
//}
//pub inline fn SDL_clamp(x: anytype, a: anytype, b: anytype) @TypeOf(if (x < a) a else if (x > b) b else x) {
//    _ = &x;
//    _ = &a;
//    _ = &b;
//    return if (x < a) a else if (x > b) b else x;
//}
//pub const SDL_copyp = @compileError("unable to translate C expr: unexpected token '{'");
//// ./include/SDL3/SDL_stdinc.h:1471:9
//pub const SDL_zero = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1513:9
//pub const SDL_zerop = @compileError("unable to translate C expr: unexpected token '*'");
//// ./include/SDL3/SDL_stdinc.h:1514:9
//pub const SDL_zeroa = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1515:9
//pub const SDL_INVALID_UNICODE_CODEPOINT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFD, .hex);
//pub const SDL_PI_D = @as(f64, 3.141592653589793238462643383279502884);
//pub const SDL_PI_F = @as(f32, 3.141592653589793238462643383279502884);
//pub const SDL_ICONV_ERROR = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub const SDL_ICONV_E2BIG = @import("std").zig.c_translation.cast(usize, -@as(c_int, 2));
//pub const SDL_ICONV_EILSEQ = @import("std").zig.c_translation.cast(usize, -@as(c_int, 3));
//pub const SDL_ICONV_EINVAL = @import("std").zig.c_translation.cast(usize, -@as(c_int, 4));
//pub inline fn SDL_iconv_utf8_locale(S: anytype) @TypeOf(SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1))) {
//    _ = &S;
//    return SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1));
//}
//pub inline fn SDL_iconv_utf8_ucs2(S: anytype) [*c]Uint16 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint16, SDL_iconv_string("UCS-2", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_utf8_ucs4(S: anytype) [*c]Uint32 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint32, SDL_iconv_string("UCS-4", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_wchar_utf8(S: anytype) @TypeOf(SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t))) {
//    _ = &S;
//    return SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t));
//}
//pub inline fn SDL_Unsupported() @TypeOf(SDL_SetError("That operation is not supported")) {
//    return SDL_SetError("That operation is not supported");
//}
//pub inline fn SDL_InvalidParamError(param: anytype) @TypeOf(SDL_SetError("Parameter '%s' is invalid", param)) {
//    _ = &param;
//    return SDL_SetError("Parameter '%s' is invalid", param);
//}
//pub const SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED = "SDL_ALLOW_ALT_TAB_WHILE_GRABBED";
pub const allow_alt_tab_while_grabbed = "ALLOW_ALT_TAB_WHILE_GRABBED";
//pub const SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY = "SDL_ANDROID_ALLOW_RECREATE_ACTIVITY";
pub const android_allow_recreate_activity = "ANDROID_ALLOW_RECREATE_ACTIVITY";
//pub const SDL_HINT_ANDROID_BLOCK_ON_PAUSE = "SDL_ANDROID_BLOCK_ON_PAUSE";
pub const android_block_on_pause = "ANDROID_BLOCK_ON_PAUSE";
//pub const SDL_HINT_ANDROID_TRAP_BACK_BUTTON = "SDL_ANDROID_TRAP_BACK_BUTTON";
pub const android_trap_back_button = "ANDROID_TRAP_BACK_BUTTON";
//pub const SDL_HINT_APP_ID = "SDL_APP_ID";
pub const app_id = "APP_ID";
//pub const SDL_HINT_APP_NAME = "SDL_APP_NAME";
pub const app_name = "APP_NAME";
//pub const SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS = "SDL_APPLE_TV_CONTROLLER_UI_EVENTS";
pub const apple_tv_controller_ui_events = "APPLE_TV_CONTROLLER_UI_EVENTS";
//pub const SDL_HINT_APPLE_TV_REMOTE_ALLOW_ROTATION = "SDL_APPLE_TV_REMOTE_ALLOW_ROTATION";
pub const apple_tv_remote_allow_rotation = "APPLE_TV_REMOTE_ALLOW_ROTATION";
//pub const SDL_HINT_AUDIO_ALSA_DEFAULT_DEVICE = "SDL_AUDIO_ALSA_DEFAULT_DEVICE";
pub const audio_alsa_default_device = "AUDIO_ALSA_DEFAULT_DEVICE";
//pub const SDL_HINT_AUDIO_CATEGORY = "SDL_AUDIO_CATEGORY";
pub const audio_category = "AUDIO_CATEGORY";
//pub const SDL_HINT_AUDIO_CHANNELS = "SDL_AUDIO_CHANNELS";
pub const audio_channels = "AUDIO_CHANNELS";
//pub const SDL_HINT_AUDIO_DEVICE_APP_ICON_NAME = "SDL_AUDIO_DEVICE_APP_ICON_NAME";
pub const audio_device_app_icon_name = "AUDIO_DEVICE_APP_ICON_NAME";
//pub const SDL_HINT_AUDIO_DEVICE_SAMPLE_FRAMES = "SDL_AUDIO_DEVICE_SAMPLE_FRAMES";
pub const audio_device_sample_frames = "AUDIO_DEVICE_SAMPLE_FRAMES";
//pub const SDL_HINT_AUDIO_DEVICE_STREAM_NAME = "SDL_AUDIO_DEVICE_STREAM_NAME";
pub const audio_device_stream_name = "AUDIO_DEVICE_STREAM_NAME";
//pub const SDL_HINT_AUDIO_DEVICE_STREAM_ROLE = "SDL_AUDIO_DEVICE_STREAM_ROLE";
pub const audio_device_stream_role = "AUDIO_DEVICE_STREAM_ROLE";
//pub const SDL_HINT_AUDIO_DISK_INPUT_FILE = "SDL_AUDIO_DISK_INPUT_FILE";
pub const audio_disk_input_file = "AUDIO_DISK_INPUT_FILE";
//pub const SDL_HINT_AUDIO_DISK_OUTPUT_FILE = "SDL_AUDIO_DISK_OUTPUT_FILE";
pub const audio_disk_output_file = "AUDIO_DISK_OUTPUT_FILE";
//pub const SDL_HINT_AUDIO_DISK_TIMESCALE = "SDL_AUDIO_DISK_TIMESCALE";
pub const audio_disk_timescale = "AUDIO_DISK_TIMESCALE";
//pub const SDL_HINT_AUDIO_DRIVER = "SDL_AUDIO_DRIVER";
pub const audio_driver = "AUDIO_DRIVER";
//pub const SDL_HINT_AUDIO_DUMMY_TIMESCALE = "SDL_AUDIO_DUMMY_TIMESCALE";
pub const audio_dummy_timescale = "AUDIO_DUMMY_TIMESCALE";
//pub const SDL_HINT_AUDIO_FORMAT = "SDL_AUDIO_FORMAT";
pub const audio_format = "AUDIO_FORMAT";
//pub const SDL_HINT_AUDIO_FREQUENCY = "SDL_AUDIO_FREQUENCY";
pub const audio_frequency = "AUDIO_FREQUENCY";
//pub const SDL_HINT_AUDIO_INCLUDE_MONITORS = "SDL_AUDIO_INCLUDE_MONITORS";
pub const audio_include_monitors = "AUDIO_INCLUDE_MONITORS";
//pub const SDL_HINT_AUTO_UPDATE_JOYSTICKS = "SDL_AUTO_UPDATE_JOYSTICKS";
pub const auto_update_joysticks = "AUTO_UPDATE_JOYSTICKS";
//pub const SDL_HINT_AUTO_UPDATE_SENSORS = "SDL_AUTO_UPDATE_SENSORS";
pub const auto_update_sensors = "AUTO_UPDATE_SENSORS";
//pub const SDL_HINT_BMP_SAVE_LEGACY_FORMAT = "SDL_BMP_SAVE_LEGACY_FORMAT";
pub const bmp_save_legacy_format = "BMP_SAVE_LEGACY_FORMAT";
//pub const SDL_HINT_CAMERA_DRIVER = "SDL_CAMERA_DRIVER";
pub const camera_driver = "CAMERA_DRIVER";
//pub const SDL_HINT_CPU_FEATURE_MASK = "SDL_CPU_FEATURE_MASK";
pub const cpu_feature_mask = "CPU_FEATURE_MASK";
//pub const SDL_HINT_JOYSTICK_DIRECTINPUT = "SDL_JOYSTICK_DIRECTINPUT";
pub const joystick_directinput = "JOYSTICK_DIRECTINPUT";
//pub const SDL_HINT_FILE_DIALOG_DRIVER = "SDL_FILE_DIALOG_DRIVER";
pub const file_dialog_driver = "FILE_DIALOG_DRIVER";
//pub const SDL_HINT_DISPLAY_USABLE_BOUNDS = "SDL_DISPLAY_USABLE_BOUNDS";
pub const display_usable_bounds = "DISPLAY_USABLE_BOUNDS";
//pub const SDL_HINT_EMSCRIPTEN_ASYNCIFY = "SDL_EMSCRIPTEN_ASYNCIFY";
pub const emscripten_asyncify = "EMSCRIPTEN_ASYNCIFY";
//pub const SDL_HINT_EMSCRIPTEN_CANVAS_SELECTOR = "SDL_EMSCRIPTEN_CANVAS_SELECTOR";
pub const emscripten_canvas_selector = "EMSCRIPTEN_CANVAS_SELECTOR";
//pub const SDL_HINT_EMSCRIPTEN_KEYBOARD_ELEMENT = "SDL_EMSCRIPTEN_KEYBOARD_ELEMENT";
pub const emscripten_keyboard_element = "EMSCRIPTEN_KEYBOARD_ELEMENT";
//pub const SDL_HINT_ENABLE_SCREEN_KEYBOARD = "SDL_ENABLE_SCREEN_KEYBOARD";
pub const enable_screen_keyboard = "ENABLE_SCREEN_KEYBOARD";
//pub const SDL_HINT_EVDEV_DEVICES = "SDL_EVDEV_DEVICES";
pub const evdev_devices = "EVDEV_DEVICES";
//pub const SDL_HINT_EVENT_LOGGING = "SDL_EVENT_LOGGING";
pub const event_logging = "EVENT_LOGGING";
//pub const SDL_HINT_FORCE_RAISEWINDOW = "SDL_FORCE_RAISEWINDOW";
pub const force_raisewindow = "FORCE_RAISEWINDOW";
//pub const SDL_HINT_FRAMEBUFFER_ACCELERATION = "SDL_FRAMEBUFFER_ACCELERATION";
pub const framebuffer_acceleration = "FRAMEBUFFER_ACCELERATION";
//pub const SDL_HINT_GAMECONTROLLERCONFIG = "SDL_GAMECONTROLLERCONFIG";
pub const gamecontrollerconfig = "GAMECONTROLLERCONFIG";
//pub const SDL_HINT_GAMECONTROLLERCONFIG_FILE = "SDL_GAMECONTROLLERCONFIG_FILE";
pub const gamecontrollerconfig_file = "GAMECONTROLLERCONFIG_FILE";
//pub const SDL_HINT_GAMECONTROLLERTYPE = "SDL_GAMECONTROLLERTYPE";
pub const gamecontrollertype = "GAMECONTROLLERTYPE";
//pub const SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES = "SDL_GAMECONTROLLER_IGNORE_DEVICES";
pub const gamecontroller_ignore_devices = "GAMECONTROLLER_IGNORE_DEVICES";
//pub const SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT = "SDL_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT";
pub const gamecontroller_ignore_devices_except = "GAMECONTROLLER_IGNORE_DEVICES_EXCEPT";
//pub const SDL_HINT_GAMECONTROLLER_SENSOR_FUSION = "SDL_GAMECONTROLLER_SENSOR_FUSION";
pub const gamecontroller_sensor_fusion = "GAMECONTROLLER_SENSOR_FUSION";
//pub const SDL_HINT_GDK_TEXTINPUT_DEFAULT_TEXT = "SDL_GDK_TEXTINPUT_DEFAULT_TEXT";
pub const gdk_textinput_default_text = "GDK_TEXTINPUT_DEFAULT_TEXT";
//pub const SDL_HINT_GDK_TEXTINPUT_DESCRIPTION = "SDL_GDK_TEXTINPUT_DESCRIPTION";
pub const gdk_textinput_description = "GDK_TEXTINPUT_DESCRIPTION";
//pub const SDL_HINT_GDK_TEXTINPUT_MAX_LENGTH = "SDL_GDK_TEXTINPUT_MAX_LENGTH";
pub const gdk_textinput_max_length = "GDK_TEXTINPUT_MAX_LENGTH";
//pub const SDL_HINT_GDK_TEXTINPUT_SCOPE = "SDL_GDK_TEXTINPUT_SCOPE";
pub const gdk_textinput_scope = "GDK_TEXTINPUT_SCOPE";
//pub const SDL_HINT_GDK_TEXTINPUT_TITLE = "SDL_GDK_TEXTINPUT_TITLE";
pub const gdk_textinput_title = "GDK_TEXTINPUT_TITLE";
//pub const SDL_HINT_HIDAPI_LIBUSB = "SDL_HIDAPI_LIBUSB";
pub const hidapi_libusb = "HIDAPI_LIBUSB";
//pub const SDL_HINT_HIDAPI_LIBUSB_WHITELIST = "SDL_HIDAPI_LIBUSB_WHITELIST";
pub const hidapi_libusb_whitelist = "HIDAPI_LIBUSB_WHITELIST";
//pub const SDL_HINT_HIDAPI_UDEV = "SDL_HIDAPI_UDEV";
pub const hidapi_udev = "HIDAPI_UDEV";
//pub const SDL_HINT_GPU_DRIVER = "SDL_GPU_DRIVER";
pub const gpu_driver = "GPU_DRIVER";
//pub const SDL_HINT_HIDAPI_ENUMERATE_ONLY_CONTROLLERS = "SDL_HIDAPI_ENUMERATE_ONLY_CONTROLLERS";
pub const hidapi_enumerate_only_controllers = "HIDAPI_ENUMERATE_ONLY_CONTROLLERS";
//pub const SDL_HINT_HIDAPI_IGNORE_DEVICES = "SDL_HIDAPI_IGNORE_DEVICES";
pub const hidapi_ignore_devices = "HIDAPI_IGNORE_DEVICES";
//pub const SDL_HINT_IME_IMPLEMENTED_UI = "SDL_IME_IMPLEMENTED_UI";
pub const ime_implemented_ui = "IME_IMPLEMENTED_UI";
//pub const SDL_HINT_IOS_HIDE_HOME_INDICATOR = "SDL_IOS_HIDE_HOME_INDICATOR";
pub const ios_hide_home_indicator = "IOS_HIDE_HOME_INDICATOR";
//pub const SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS = "SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS";
pub const joystick_allow_background_events = "JOYSTICK_ALLOW_BACKGROUND_EVENTS";
//pub const SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES = "SDL_JOYSTICK_ARCADESTICK_DEVICES";
pub const joystick_arcadestick_devices = "JOYSTICK_ARCADESTICK_DEVICES";
//pub const SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED = "SDL_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED";
pub const joystick_arcadestick_devices_excluded = "JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_BLACKLIST_DEVICES = "SDL_JOYSTICK_BLACKLIST_DEVICES";
pub const joystick_blacklist_devices = "JOYSTICK_BLACKLIST_DEVICES";
//pub const SDL_HINT_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED = "SDL_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED";
pub const joystick_blacklist_devices_excluded = "JOYSTICK_BLACKLIST_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_DEVICE = "SDL_JOYSTICK_DEVICE";
pub const joystick_device = "JOYSTICK_DEVICE";
//pub const SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES = "SDL_JOYSTICK_FLIGHTSTICK_DEVICES";
pub const joystick_flightstick_devices = "JOYSTICK_FLIGHTSTICK_DEVICES";
//pub const SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED = "SDL_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED";
pub const joystick_flightstick_devices_excluded = "JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_GAMEINPUT = "SDL_JOYSTICK_GAMEINPUT";
pub const joystick_gameinput = "JOYSTICK_GAMEINPUT";
//pub const SDL_HINT_JOYSTICK_GAMECUBE_DEVICES = "SDL_JOYSTICK_GAMECUBE_DEVICES";
pub const joystick_gamecube_devices = "JOYSTICK_GAMECUBE_DEVICES";
//pub const SDL_HINT_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED = "SDL_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED";
pub const joystick_gamecube_devices_excluded = "JOYSTICK_GAMECUBE_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_HIDAPI = "SDL_JOYSTICK_HIDAPI";
pub const joystick_hidapi = "JOYSTICK_HIDAPI";
//pub const SDL_HINT_JOYSTICK_HIDAPI_COMBINE_JOY_CONS = "SDL_JOYSTICK_HIDAPI_COMBINE_JOY_CONS";
pub const joystick_hidapi_combine_joy_cons = "JOYSTICK_HIDAPI_COMBINE_JOY_CONS";
//pub const SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE = "SDL_JOYSTICK_HIDAPI_GAMECUBE";
pub const joystick_hidapi_gamecube = "JOYSTICK_HIDAPI_GAMECUBE";
//pub const SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE = "SDL_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE";
pub const joystick_hidapi_gamecube_rumble_brake = "JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE";
//pub const SDL_HINT_JOYSTICK_HIDAPI_JOY_CONS = "SDL_JOYSTICK_HIDAPI_JOY_CONS";
pub const joystick_hidapi_joy_cons = "JOYSTICK_HIDAPI_JOY_CONS";
//pub const SDL_HINT_JOYSTICK_HIDAPI_JOYCON_HOME_LED = "SDL_JOYSTICK_HIDAPI_JOYCON_HOME_LED";
pub const joystick_hidapi_joycon_home_led = "JOYSTICK_HIDAPI_JOYCON_HOME_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_LUNA = "SDL_JOYSTICK_HIDAPI_LUNA";
pub const joystick_hidapi_luna = "JOYSTICK_HIDAPI_LUNA";
//pub const SDL_HINT_JOYSTICK_HIDAPI_NINTENDO_CLASSIC = "SDL_JOYSTICK_HIDAPI_NINTENDO_CLASSIC";
pub const joystick_hidapi_nintendo_classic = "JOYSTICK_HIDAPI_NINTENDO_CLASSIC";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS3 = "SDL_JOYSTICK_HIDAPI_PS3";
pub const joystick_hidapi_ps3 = "JOYSTICK_HIDAPI_PS3";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER = "SDL_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER";
pub const joystick_hidapi_ps3_sixaxis_driver = "JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS4 = "SDL_JOYSTICK_HIDAPI_PS4";
pub const joystick_hidapi_ps4 = "JOYSTICK_HIDAPI_PS4";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL = "SDL_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL";
pub const joystick_hidapi_ps4_report_interval = "JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE = "SDL_JOYSTICK_HIDAPI_PS4_RUMBLE";
pub const joystick_hidapi_ps4_rumble = "JOYSTICK_HIDAPI_PS4_RUMBLE";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS5 = "SDL_JOYSTICK_HIDAPI_PS5";
pub const joystick_hidapi_ps5 = "JOYSTICK_HIDAPI_PS5";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS5_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_PS5_PLAYER_LED";
pub const joystick_hidapi_ps5_player_led = "JOYSTICK_HIDAPI_PS5_PLAYER_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_PS5_RUMBLE = "SDL_JOYSTICK_HIDAPI_PS5_RUMBLE";
pub const joystick_hidapi_ps5_rumble = "JOYSTICK_HIDAPI_PS5_RUMBLE";
//pub const SDL_HINT_JOYSTICK_HIDAPI_SHIELD = "SDL_JOYSTICK_HIDAPI_SHIELD";
pub const joystick_hidapi_shield = "JOYSTICK_HIDAPI_SHIELD";
//pub const SDL_HINT_JOYSTICK_HIDAPI_STADIA = "SDL_JOYSTICK_HIDAPI_STADIA";
pub const joystick_hidapi_stadia = "JOYSTICK_HIDAPI_STADIA";
//pub const SDL_HINT_JOYSTICK_HIDAPI_STEAM = "SDL_JOYSTICK_HIDAPI_STEAM";
pub const joystick_hidapi_steam = "JOYSTICK_HIDAPI_STEAM";
//pub const SDL_HINT_JOYSTICK_HIDAPI_STEAMDECK = "SDL_JOYSTICK_HIDAPI_STEAMDECK";
pub const joystick_hidapi_steamdeck = "JOYSTICK_HIDAPI_STEAMDECK";
//pub const SDL_HINT_JOYSTICK_HIDAPI_SWITCH = "SDL_JOYSTICK_HIDAPI_SWITCH";
pub const joystick_hidapi_switch = "JOYSTICK_HIDAPI_SWITCH";
//pub const SDL_HINT_JOYSTICK_HIDAPI_SWITCH_HOME_LED = "SDL_JOYSTICK_HIDAPI_SWITCH_HOME_LED";
pub const joystick_hidapi_switch_home_led = "JOYSTICK_HIDAPI_SWITCH_HOME_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED";
pub const joystick_hidapi_switch_player_led = "JOYSTICK_HIDAPI_SWITCH_PLAYER_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS = "SDL_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS";
pub const joystick_hidapi_vertical_joy_cons = "JOYSTICK_HIDAPI_VERTICAL_JOY_CONS";
//pub const SDL_HINT_JOYSTICK_HIDAPI_WII = "SDL_JOYSTICK_HIDAPI_WII";
pub const joystick_hidapi_wii = "JOYSTICK_HIDAPI_WII";
//pub const SDL_HINT_JOYSTICK_HIDAPI_WII_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_WII_PLAYER_LED";
pub const joystick_hidapi_wii_player_led = "JOYSTICK_HIDAPI_WII_PLAYER_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX = "SDL_JOYSTICK_HIDAPI_XBOX";
pub const joystick_hidapi_xbox = "JOYSTICK_HIDAPI_XBOX";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360 = "SDL_JOYSTICK_HIDAPI_XBOX_360";
pub const joystick_hidapi_xbox_360 = "JOYSTICK_HIDAPI_XBOX_360";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED";
pub const joystick_hidapi_xbox_360_player_led = "JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_WIRELESS = "SDL_JOYSTICK_HIDAPI_XBOX_360_WIRELESS";
pub const joystick_hidapi_xbox_360_wireless = "JOYSTICK_HIDAPI_XBOX_360_WIRELESS";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE = "SDL_JOYSTICK_HIDAPI_XBOX_ONE";
pub const joystick_hidapi_xbox_one = "JOYSTICK_HIDAPI_XBOX_ONE";
//pub const SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED = "SDL_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED";
pub const joystick_hidapi_xbox_one_home_led = "JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED";
//pub const SDL_HINT_JOYSTICK_IOKIT = "SDL_JOYSTICK_IOKIT";
pub const joystick_iokit = "JOYSTICK_IOKIT";
//pub const SDL_HINT_JOYSTICK_LINUX_CLASSIC = "SDL_JOYSTICK_LINUX_CLASSIC";
pub const joystick_linux_classic = "JOYSTICK_LINUX_CLASSIC";
//pub const SDL_HINT_JOYSTICK_LINUX_DEADZONES = "SDL_JOYSTICK_LINUX_DEADZONES";
pub const joystick_linux_deadzones = "JOYSTICK_LINUX_DEADZONES";
//pub const SDL_HINT_JOYSTICK_LINUX_DIGITAL_HATS = "SDL_JOYSTICK_LINUX_DIGITAL_HATS";
pub const joystick_linux_digital_hats = "JOYSTICK_LINUX_DIGITAL_HATS";
//pub const SDL_HINT_JOYSTICK_LINUX_HAT_DEADZONES = "SDL_JOYSTICK_LINUX_HAT_DEADZONES";
pub const joystick_linux_hat_deadzones = "JOYSTICK_LINUX_HAT_DEADZONES";
//pub const SDL_HINT_JOYSTICK_MFI = "SDL_JOYSTICK_MFI";
pub const joystick_mfi = "JOYSTICK_MFI";
//pub const SDL_HINT_JOYSTICK_RAWINPUT = "SDL_JOYSTICK_RAWINPUT";
pub const joystick_rawinput = "JOYSTICK_RAWINPUT";
//pub const SDL_HINT_JOYSTICK_RAWINPUT_CORRELATE_XINPUT = "SDL_JOYSTICK_RAWINPUT_CORRELATE_XINPUT";
pub const joystick_rawinput_correlate_xinput = "JOYSTICK_RAWINPUT_CORRELATE_XINPUT";
//pub const SDL_HINT_JOYSTICK_ROG_CHAKRAM = "SDL_JOYSTICK_ROG_CHAKRAM";
pub const joystick_rog_chakram = "JOYSTICK_ROG_CHAKRAM";
//pub const SDL_HINT_JOYSTICK_THREAD = "SDL_JOYSTICK_THREAD";
pub const joystick_thread = "JOYSTICK_THREAD";
//pub const SDL_HINT_JOYSTICK_THROTTLE_DEVICES = "SDL_JOYSTICK_THROTTLE_DEVICES";
pub const joystick_throttle_devices = "JOYSTICK_THROTTLE_DEVICES";
//pub const SDL_HINT_JOYSTICK_THROTTLE_DEVICES_EXCLUDED = "SDL_JOYSTICK_THROTTLE_DEVICES_EXCLUDED";
pub const joystick_throttle_devices_excluded = "JOYSTICK_THROTTLE_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_WGI = "SDL_JOYSTICK_WGI";
pub const joystick_wgi = "JOYSTICK_WGI";
//pub const SDL_HINT_JOYSTICK_WHEEL_DEVICES = "SDL_JOYSTICK_WHEEL_DEVICES";
pub const joystick_wheel_devices = "JOYSTICK_WHEEL_DEVICES";
//pub const SDL_HINT_JOYSTICK_WHEEL_DEVICES_EXCLUDED = "SDL_JOYSTICK_WHEEL_DEVICES_EXCLUDED";
pub const joystick_wheel_devices_excluded = "JOYSTICK_WHEEL_DEVICES_EXCLUDED";
//pub const SDL_HINT_JOYSTICK_ZERO_CENTERED_DEVICES = "SDL_JOYSTICK_ZERO_CENTERED_DEVICES";
pub const joystick_zero_centered_devices = "JOYSTICK_ZERO_CENTERED_DEVICES";
//pub const SDL_HINT_KEYCODE_OPTIONS = "SDL_KEYCODE_OPTIONS";
pub const keycode_options = "KEYCODE_OPTIONS";
//pub const SDL_HINT_KMSDRM_DEVICE_INDEX = "SDL_KMSDRM_DEVICE_INDEX";
pub const kmsdrm_device_index = "KMSDRM_DEVICE_INDEX";
//pub const SDL_HINT_KMSDRM_REQUIRE_DRM_MASTER = "SDL_KMSDRM_REQUIRE_DRM_MASTER";
pub const kmsdrm_require_drm_master = "KMSDRM_REQUIRE_DRM_MASTER";
//pub const SDL_HINT_LOGGING = "SDL_LOGGING";
pub const logging = "LOGGING";
//pub const SDL_HINT_MAC_BACKGROUND_APP = "SDL_MAC_BACKGROUND_APP";
pub const mac_background_app = "MAC_BACKGROUND_APP";
//pub const SDL_HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK = "SDL_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK";
pub const mac_ctrl_click_emulate_right_click = "MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK";
//pub const SDL_HINT_MAC_OPENGL_ASYNC_DISPATCH = "SDL_MAC_OPENGL_ASYNC_DISPATCH";
pub const mac_opengl_async_dispatch = "MAC_OPENGL_ASYNC_DISPATCH";
//pub const SDL_HINT_MAIN_CALLBACK_RATE = "SDL_MAIN_CALLBACK_RATE";
pub const main_callback_rate = "MAIN_CALLBACK_RATE";
//pub const SDL_HINT_MOUSE_AUTO_CAPTURE = "SDL_MOUSE_AUTO_CAPTURE";
pub const mouse_auto_capture = "MOUSE_AUTO_CAPTURE";
//pub const SDL_HINT_MOUSE_DOUBLE_CLICK_RADIUS = "SDL_MOUSE_DOUBLE_CLICK_RADIUS";
pub const mouse_double_click_radius = "MOUSE_DOUBLE_CLICK_RADIUS";
//pub const SDL_HINT_MOUSE_DOUBLE_CLICK_TIME = "SDL_MOUSE_DOUBLE_CLICK_TIME";
pub const mouse_double_click_time = "MOUSE_DOUBLE_CLICK_TIME";
//pub const SDL_HINT_MOUSE_EMULATE_WARP_WITH_RELATIVE = "SDL_MOUSE_EMULATE_WARP_WITH_RELATIVE";
pub const mouse_emulate_warp_with_relative = "MOUSE_EMULATE_WARP_WITH_RELATIVE";
//pub const SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH = "SDL_MOUSE_FOCUS_CLICKTHROUGH";
pub const mouse_focus_clickthrough = "MOUSE_FOCUS_CLICKTHROUGH";
//pub const SDL_HINT_MOUSE_NORMAL_SPEED_SCALE = "SDL_MOUSE_NORMAL_SPEED_SCALE";
pub const mouse_normal_speed_scale = "MOUSE_NORMAL_SPEED_SCALE";
//pub const SDL_HINT_MOUSE_RELATIVE_MODE_CENTER = "SDL_MOUSE_RELATIVE_MODE_CENTER";
pub const mouse_relative_mode_center = "MOUSE_RELATIVE_MODE_CENTER";
//pub const SDL_HINT_MOUSE_RELATIVE_MODE_WARP = "SDL_MOUSE_RELATIVE_MODE_WARP";
pub const mouse_relative_mode_warp = "MOUSE_RELATIVE_MODE_WARP";
//pub const SDL_HINT_MOUSE_RELATIVE_SPEED_SCALE = "SDL_MOUSE_RELATIVE_SPEED_SCALE";
pub const mouse_relative_speed_scale = "MOUSE_RELATIVE_SPEED_SCALE";
//pub const SDL_HINT_MOUSE_RELATIVE_SYSTEM_SCALE = "SDL_MOUSE_RELATIVE_SYSTEM_SCALE";
pub const mouse_relative_system_scale = "MOUSE_RELATIVE_SYSTEM_SCALE";
//pub const SDL_HINT_MOUSE_RELATIVE_WARP_MOTION = "SDL_MOUSE_RELATIVE_WARP_MOTION";
pub const mouse_relative_warp_motion = "MOUSE_RELATIVE_WARP_MOTION";
//pub const SDL_HINT_MOUSE_RELATIVE_CURSOR_VISIBLE = "SDL_MOUSE_RELATIVE_CURSOR_VISIBLE";
pub const mouse_relative_cursor_visible = "MOUSE_RELATIVE_CURSOR_VISIBLE";
//pub const SDL_HINT_MOUSE_RELATIVE_CLIP_INTERVAL = "SDL_MOUSE_RELATIVE_CLIP_INTERVAL";
pub const mouse_relative_clip_interval = "MOUSE_RELATIVE_CLIP_INTERVAL";
//pub const SDL_HINT_MOUSE_TOUCH_EVENTS = "SDL_MOUSE_TOUCH_EVENTS";
pub const mouse_touch_events = "MOUSE_TOUCH_EVENTS";
//pub const SDL_HINT_MUTE_CONSOLE_KEYBOARD = "SDL_MUTE_CONSOLE_KEYBOARD";
pub const mute_console_keyboard = "MUTE_CONSOLE_KEYBOARD";
//pub const SDL_HINT_NO_SIGNAL_HANDLERS = "SDL_NO_SIGNAL_HANDLERS";
pub const no_signal_handlers = "NO_SIGNAL_HANDLERS";
//pub const SDL_HINT_OPENGL_LIBRARY = "SDL_OPENGL_LIBRARY";
pub const opengl_library = "OPENGL_LIBRARY";
//pub const SDL_HINT_OPENGL_ES_DRIVER = "SDL_OPENGL_ES_DRIVER";
pub const opengl_es_driver = "OPENGL_ES_DRIVER";
//pub const SDL_HINT_ORIENTATIONS = "SDL_ORIENTATIONS";
pub const orientations = "ORIENTATIONS";
//pub const SDL_HINT_POLL_SENTINEL = "SDL_POLL_SENTINEL";
pub const poll_sentinel = "POLL_SENTINEL";
//pub const SDL_HINT_PREFERRED_LOCALES = "SDL_PREFERRED_LOCALES";
pub const preferred_locales = "PREFERRED_LOCALES";
//pub const SDL_HINT_QUIT_ON_LAST_WINDOW_CLOSE = "SDL_QUIT_ON_LAST_WINDOW_CLOSE";
pub const quit_on_last_window_close = "QUIT_ON_LAST_WINDOW_CLOSE";
//pub const SDL_HINT_RENDER_DIRECT3D_THREADSAFE = "SDL_RENDER_DIRECT3D_THREADSAFE";
pub const render_direct3d_threadsafe = "RENDER_DIRECT3D_THREADSAFE";
//pub const SDL_HINT_RENDER_DIRECT3D11_DEBUG = "SDL_RENDER_DIRECT3D11_DEBUG";
pub const render_direct3d11_debug = "RENDER_DIRECT3D11_DEBUG";
//pub const SDL_HINT_RENDER_VULKAN_DEBUG = "SDL_RENDER_VULKAN_DEBUG";
pub const render_vulkan_debug = "RENDER_VULKAN_DEBUG";
//pub const SDL_HINT_RENDER_GPU_DEBUG = "SDL_RENDER_GPU_DEBUG";
pub const render_gpu_debug = "RENDER_GPU_DEBUG";
//pub const SDL_HINT_RENDER_GPU_LOW_POWER = "SDL_RENDER_GPU_LOW_POWER";
pub const render_gpu_low_power = "RENDER_GPU_LOW_POWER";
//pub const SDL_HINT_RENDER_DRIVER = "SDL_RENDER_DRIVER";
pub const render_driver = "RENDER_DRIVER";
//pub const SDL_HINT_RENDER_LINE_METHOD = "SDL_RENDER_LINE_METHOD";
pub const render_line_method = "RENDER_LINE_METHOD";
//pub const SDL_HINT_RENDER_METAL_PREFER_LOW_POWER_DEVICE = "SDL_RENDER_METAL_PREFER_LOW_POWER_DEVICE";
pub const render_metal_prefer_low_power_device = "RENDER_METAL_PREFER_LOW_POWER_DEVICE";
//pub const SDL_HINT_RENDER_VSYNC = "SDL_RENDER_VSYNC";
pub const render_vsync = "RENDER_VSYNC";
//pub const SDL_HINT_RETURN_KEY_HIDES_IME = "SDL_RETURN_KEY_HIDES_IME";
pub const return_key_hides_ime = "RETURN_KEY_HIDES_IME";
//pub const SDL_HINT_ROG_GAMEPAD_MICE = "SDL_ROG_GAMEPAD_MICE";
pub const rog_gamepad_mice = "ROG_GAMEPAD_MICE";
//pub const SDL_HINT_ROG_GAMEPAD_MICE_EXCLUDED = "SDL_ROG_GAMEPAD_MICE_EXCLUDED";
pub const rog_gamepad_mice_excluded = "ROG_GAMEPAD_MICE_EXCLUDED";
//pub const SDL_HINT_RPI_VIDEO_LAYER = "SDL_RPI_VIDEO_LAYER";
pub const rpi_video_layer = "RPI_VIDEO_LAYER";
//pub const SDL_HINT_SCREENSAVER_INHIBIT_ACTIVITY_NAME = "SDL_SCREENSAVER_INHIBIT_ACTIVITY_NAME";
pub const screensaver_inhibit_activity_name = "SCREENSAVER_INHIBIT_ACTIVITY_NAME";
//pub const SDL_HINT_SHUTDOWN_DBUS_ON_QUIT = "SDL_SHUTDOWN_DBUS_ON_QUIT";
pub const shutdown_dbus_on_quit = "SHUTDOWN_DBUS_ON_QUIT";
//pub const SDL_HINT_STORAGE_TITLE_DRIVER = "SDL_STORAGE_TITLE_DRIVER";
pub const storage_title_driver = "STORAGE_TITLE_DRIVER";
//pub const SDL_HINT_STORAGE_USER_DRIVER = "SDL_STORAGE_USER_DRIVER";
pub const storage_user_driver = "STORAGE_USER_DRIVER";
//pub const SDL_HINT_THREAD_FORCE_REALTIME_TIME_CRITICAL = "SDL_THREAD_FORCE_REALTIME_TIME_CRITICAL";
pub const thread_force_realtime_time_critical = "THREAD_FORCE_REALTIME_TIME_CRITICAL";
//pub const SDL_HINT_THREAD_PRIORITY_POLICY = "SDL_THREAD_PRIORITY_POLICY";
pub const thread_priority_policy = "THREAD_PRIORITY_POLICY";
//pub const SDL_HINT_TIMER_RESOLUTION = "SDL_TIMER_RESOLUTION";
pub const timer_resolution = "TIMER_RESOLUTION";
//pub const SDL_HINT_TOUCH_MOUSE_EVENTS = "SDL_TOUCH_MOUSE_EVENTS";
pub const touch_mouse_events = "TOUCH_MOUSE_EVENTS";
//pub const SDL_HINT_TRACKPAD_IS_TOUCH_ONLY = "SDL_TRACKPAD_IS_TOUCH_ONLY";
pub const trackpad_is_touch_only = "TRACKPAD_IS_TOUCH_ONLY";
//pub const SDL_HINT_TV_REMOTE_AS_JOYSTICK = "SDL_TV_REMOTE_AS_JOYSTICK";
pub const tv_remote_as_joystick = "TV_REMOTE_AS_JOYSTICK";
//pub const SDL_HINT_VIDEO_ALLOW_SCREENSAVER = "SDL_VIDEO_ALLOW_SCREENSAVER";
pub const video_allow_screensaver = "VIDEO_ALLOW_SCREENSAVER";
//pub const SDL_HINT_VIDEO_DOUBLE_BUFFER = "SDL_VIDEO_DOUBLE_BUFFER";
pub const video_double_buffer = "VIDEO_DOUBLE_BUFFER";
//pub const SDL_HINT_VIDEO_DRIVER = "SDL_VIDEO_DRIVER";
pub const video_driver = "VIDEO_DRIVER";
//pub const SDL_HINT_VIDEO_DUMMY_SAVE_FRAMES = "SDL_VIDEO_DUMMY_SAVE_FRAMES";
pub const video_dummy_save_frames = "VIDEO_DUMMY_SAVE_FRAMES";
//pub const SDL_HINT_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK = "SDL_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK";
pub const video_egl_allow_getdisplay_fallback = "VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK";
//pub const SDL_HINT_VIDEO_FORCE_EGL = "SDL_VIDEO_FORCE_EGL";
pub const video_force_egl = "VIDEO_FORCE_EGL";
//pub const SDL_HINT_VIDEO_MAC_FULLSCREEN_SPACES = "SDL_VIDEO_MAC_FULLSCREEN_SPACES";
pub const video_mac_fullscreen_spaces = "VIDEO_MAC_FULLSCREEN_SPACES";
//pub const SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS";
pub const video_minimize_on_focus_loss = "VIDEO_MINIMIZE_ON_FOCUS_LOSS";
//pub const SDL_HINT_VIDEO_OFFSCREEN_SAVE_FRAMES = "SDL_VIDEO_OFFSCREEN_SAVE_FRAMES";
pub const video_offscreen_save_frames = "VIDEO_OFFSCREEN_SAVE_FRAMES";
//pub const SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS = "SDL_VIDEO_SYNC_WINDOW_OPERATIONS";
pub const video_sync_window_operations = "VIDEO_SYNC_WINDOW_OPERATIONS";
//pub const SDL_HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR = "SDL_VIDEO_WAYLAND_ALLOW_LIBDECOR";
pub const video_wayland_allow_libdecor = "VIDEO_WAYLAND_ALLOW_LIBDECOR";
//pub const SDL_HINT_VIDEO_WAYLAND_MODE_EMULATION = "SDL_VIDEO_WAYLAND_MODE_EMULATION";
pub const video_wayland_mode_emulation = "VIDEO_WAYLAND_MODE_EMULATION";
//pub const SDL_HINT_VIDEO_WAYLAND_MODE_SCALING = "SDL_VIDEO_WAYLAND_MODE_SCALING";
pub const video_wayland_mode_scaling = "VIDEO_WAYLAND_MODE_SCALING";
//pub const SDL_HINT_VIDEO_WAYLAND_PREFER_LIBDECOR = "SDL_VIDEO_WAYLAND_PREFER_LIBDECOR";
pub const video_wayland_prefer_libdecor = "VIDEO_WAYLAND_PREFER_LIBDECOR";
//pub const SDL_HINT_VIDEO_WAYLAND_SCALE_TO_DISPLAY = "SDL_VIDEO_WAYLAND_SCALE_TO_DISPLAY";
pub const video_wayland_scale_to_display = "VIDEO_WAYLAND_SCALE_TO_DISPLAY";
//pub const SDL_HINT_VIDEO_WIN_D3DCOMPILER = "SDL_VIDEO_WIN_D3DCOMPILER";
pub const video_win_d3dcompiler = "VIDEO_WIN_D3DCOMPILER";
//pub const SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR = "SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR";
pub const video_x11_net_wm_bypass_compositor = "VIDEO_X11_NET_WM_BYPASS_COMPOSITOR";
//pub const SDL_HINT_VIDEO_X11_NET_WM_PING = "SDL_VIDEO_X11_NET_WM_PING";
pub const video_x11_net_wm_ping = "VIDEO_X11_NET_WM_PING";
//pub const SDL_HINT_VIDEO_X11_NODIRECTCOLOR = "SDL_VIDEO_X11_NODIRECTCOLOR";
pub const video_x11_nodirectcolor = "VIDEO_X11_NODIRECTCOLOR";
//pub const SDL_HINT_VIDEO_X11_SCALING_FACTOR = "SDL_VIDEO_X11_SCALING_FACTOR";
pub const video_x11_scaling_factor = "VIDEO_X11_SCALING_FACTOR";
//pub const SDL_HINT_VIDEO_X11_VISUALID = "SDL_VIDEO_X11_VISUALID";
pub const video_x11_visualid = "VIDEO_X11_VISUALID";
//pub const SDL_HINT_VIDEO_X11_WINDOW_VISUALID = "SDL_VIDEO_X11_WINDOW_VISUALID";
pub const video_x11_window_visualid = "VIDEO_X11_WINDOW_VISUALID";
//pub const SDL_HINT_VIDEO_X11_XRANDR = "SDL_VIDEO_X11_XRANDR";
pub const video_x11_xrandr = "VIDEO_X11_XRANDR";
//pub const SDL_HINT_VITA_ENABLE_BACK_TOUCH = "SDL_VITA_ENABLE_BACK_TOUCH";
pub const vita_enable_back_touch = "VITA_ENABLE_BACK_TOUCH";
//pub const SDL_HINT_VITA_ENABLE_FRONT_TOUCH = "SDL_VITA_ENABLE_FRONT_TOUCH";
pub const vita_enable_front_touch = "VITA_ENABLE_FRONT_TOUCH";
//pub const SDL_HINT_VITA_MODULE_PATH = "SDL_VITA_MODULE_PATH";
pub const vita_module_path = "VITA_MODULE_PATH";
//pub const SDL_HINT_VITA_PVR_INIT = "SDL_VITA_PVR_INIT";
pub const vita_pvr_init = "VITA_PVR_INIT";
//pub const SDL_HINT_VITA_RESOLUTION = "SDL_VITA_RESOLUTION";
pub const vita_resolution = "VITA_RESOLUTION";
//pub const SDL_HINT_VITA_PVR_OPENGL = "SDL_VITA_PVR_OPENGL";
pub const vita_pvr_opengl = "VITA_PVR_OPENGL";
//pub const SDL_HINT_VITA_TOUCH_MOUSE_DEVICE = "SDL_VITA_TOUCH_MOUSE_DEVICE";
pub const vita_touch_mouse_device = "VITA_TOUCH_MOUSE_DEVICE";
//pub const SDL_HINT_VULKAN_DISPLAY = "SDL_VULKAN_DISPLAY";
pub const vulkan_display = "VULKAN_DISPLAY";
//pub const SDL_HINT_VULKAN_LIBRARY = "SDL_VULKAN_LIBRARY";
pub const vulkan_library = "VULKAN_LIBRARY";
//pub const SDL_HINT_WAVE_FACT_CHUNK = "SDL_WAVE_FACT_CHUNK";
pub const wave_fact_chunk = "WAVE_FACT_CHUNK";
//pub const SDL_HINT_WAVE_CHUNK_LIMIT = "SDL_WAVE_CHUNK_LIMIT";
pub const wave_chunk_limit = "WAVE_CHUNK_LIMIT";
//pub const SDL_HINT_WAVE_RIFF_CHUNK_SIZE = "SDL_WAVE_RIFF_CHUNK_SIZE";
pub const wave_riff_chunk_size = "WAVE_RIFF_CHUNK_SIZE";
//pub const SDL_HINT_WAVE_TRUNCATION = "SDL_WAVE_TRUNCATION";
pub const wave_truncation = "WAVE_TRUNCATION";
//pub const SDL_HINT_WINDOW_ACTIVATE_WHEN_RAISED = "SDL_WINDOW_ACTIVATE_WHEN_RAISED";
pub const window_activate_when_raised = "WINDOW_ACTIVATE_WHEN_RAISED";
//pub const SDL_HINT_WINDOW_ACTIVATE_WHEN_SHOWN = "SDL_WINDOW_ACTIVATE_WHEN_SHOWN";
pub const window_activate_when_shown = "WINDOW_ACTIVATE_WHEN_SHOWN";
//pub const SDL_HINT_WINDOW_ALLOW_TOPMOST = "SDL_WINDOW_ALLOW_TOPMOST";
pub const window_allow_topmost = "WINDOW_ALLOW_TOPMOST";
//pub const SDL_HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN = "SDL_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN";
pub const window_frame_usable_while_cursor_hidden = "WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN";
//pub const SDL_HINT_WINDOWS_CLOSE_ON_ALT_F4 = "SDL_WINDOWS_CLOSE_ON_ALT_F4";
pub const windows_close_on_alt_f4 = "WINDOWS_CLOSE_ON_ALT_F4";
//pub const SDL_HINT_WINDOWS_ENABLE_MENU_MNEMONICS = "SDL_WINDOWS_ENABLE_MENU_MNEMONICS";
pub const windows_enable_menu_mnemonics = "WINDOWS_ENABLE_MENU_MNEMONICS";
//pub const SDL_HINT_WINDOWS_ENABLE_MESSAGELOOP = "SDL_WINDOWS_ENABLE_MESSAGELOOP";
pub const windows_enable_messageloop = "WINDOWS_ENABLE_MESSAGELOOP";
//pub const SDL_HINT_WINDOWS_GAMEINPUT = "SDL_WINDOWS_GAMEINPUT";
pub const windows_gameinput = "WINDOWS_GAMEINPUT";
//pub const SDL_HINT_WINDOWS_RAW_KEYBOARD = "SDL_WINDOWS_RAW_KEYBOARD";
pub const windows_raw_keyboard = "WINDOWS_RAW_KEYBOARD";
//pub const SDL_HINT_WINDOWS_FORCE_SEMAPHORE_KERNEL = "SDL_WINDOWS_FORCE_SEMAPHORE_KERNEL";
pub const windows_force_semaphore_kernel = "WINDOWS_FORCE_SEMAPHORE_KERNEL";
//pub const SDL_HINT_WINDOWS_INTRESOURCE_ICON = "SDL_WINDOWS_INTRESOURCE_ICON";
pub const windows_intresource_icon = "WINDOWS_INTRESOURCE_ICON";
//pub const SDL_HINT_WINDOWS_INTRESOURCE_ICON_SMALL = "SDL_WINDOWS_INTRESOURCE_ICON_SMALL";
pub const windows_intresource_icon_small = "WINDOWS_INTRESOURCE_ICON_SMALL";
//pub const SDL_HINT_WINDOWS_USE_D3D9EX = "SDL_WINDOWS_USE_D3D9EX";
pub const windows_use_d3d9ex = "WINDOWS_USE_D3D9EX";
//pub const SDL_HINT_WINDOWS_ERASE_BACKGROUND_MODE = "SDL_WINDOWS_ERASE_BACKGROUND_MODE";
pub const windows_erase_background_mode = "WINDOWS_ERASE_BACKGROUND_MODE";
//pub const SDL_HINT_X11_FORCE_OVERRIDE_REDIRECT = "SDL_X11_FORCE_OVERRIDE_REDIRECT";
pub const x11_force_override_redirect = "X11_FORCE_OVERRIDE_REDIRECT";
//pub const SDL_HINT_X11_WINDOW_TYPE = "SDL_X11_WINDOW_TYPE";
pub const x11_window_type = "X11_WINDOW_TYPE";
//pub const SDL_HINT_X11_XCB_LIBRARY = "SDL_X11_XCB_LIBRARY";
pub const x11_xcb_library = "X11_XCB_LIBRARY";
//pub const SDL_HINT_XINPUT_ENABLED = "SDL_XINPUT_ENABLED";
pub const xinput_enabled = "XINPUT_ENABLED";
//pub const SDL_HINT_ASSERT = "SDL_ASSERT";
pub const assert = "ASSERT";
//pub const threadlocaleinfostruct = struct_threadlocaleinfostruct;
//pub const threadmbcinfostruct = struct_threadmbcinfostruct;
//pub const __lc_time_data = struct___lc_time_data;
//pub const localeinfo_struct = struct_localeinfo_struct;
//pub const tagLC_ID = struct_tagLC_ID;
//pub const _iobuf = struct__iobuf;
//pub const _wfinddata32_t = struct__wfinddata32_t;
//pub const _wfinddata32i64_t = struct__wfinddata32i64_t;
//pub const _wfinddata64i32_t = struct__wfinddata64i32_t;
//pub const _wfinddata64_t = struct__wfinddata64_t;
//pub const _stat32 = struct__stat32;
//pub const stat = struct_stat;
//pub const _stat32i64 = struct__stat32i64;
//pub const _stat64i32 = struct__stat64i32;
//pub const _stat64 = struct__stat64;
//pub const tm = struct_tm;
//pub const SDL_iconv_data_t = struct_SDL_iconv_data_t;
