load(
    "@rules_cc_toolchain//third_party:gcc_arm_none_eabi_10_3_2021_10_x86_64_helpers.bzl",
    "gcc_arm_none_cc_toolchain_import",
)
load(
    "@rules_cc_toolchain//cc_toolchain:sysroot.bzl",
    "sysroot_package",
)
load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

sysroot_package(
    name = "sysroot",
    visibility = ["//visibility:public"],
)

LIBC_INCLUDES = [
    "arm-none-eabi/include",
    "lib/gcc/arm-none-eabi/10.3.1/include-fixed",
    "lib/gcc/arm-none-eabi/10.3.1/include",
]

LIBCC_INCLUDES = [
    "arm-none-eabi/include/c++/10.3.1",
    "arm-none-eabi/include/c++/10.3.1/arm-none-eabi",
    "arm-none-eabi/include/c++/10.3.1/backward",
]

label_flag(
    name = "system_calls",
    build_setting_default = ":nosys",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

CRT_OBJECTS = [
    "crti",
    "crtn",
    "crtbegin",
    "crtend",
]

[
    gcc_arm_none_cc_toolchain_import(
        name = libname,
        libname = libname + ".o",
        libprefix = "lib/gcc/arm-none-eabi/10.3.1/thumb",
    )
    for libname in CRT_OBJECTS
]

cc_toolchain_import(
    name = "startup_libs",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = CRT_OBJECTS,
)

# Provides semihosted system calls. i.e. using some special debugging
# functionality the target forwards system calls to the host. This
# implementation requires a target to be connected to a debugger,
# otherwise the code will be non-functional.
gcc_arm_none_cc_toolchain_import(
    name = "rdimon_nano",
    hdrs = glob([include + "/**/*.h" for include in LIBC_INCLUDES]),
    includes = LIBC_INCLUDES,
    libname = "librdimon.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# Provides stubbed system calls. i.e. system calls will run but will not do
# anything.
gcc_arm_none_cc_toolchain_import(
    name = "nosys",
    hdrs = glob([include + "/**/*.h" for include in LIBC_INCLUDES]),
    includes = LIBC_INCLUDES,
    libname = "libnosys.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# Required for math library support.
gcc_arm_none_cc_toolchain_import(
    name = "math",
    hdrs = glob([include + "/**/*.h" for include in LIBC_INCLUDES]),
    includes = LIBC_INCLUDES,
    libname = "libm.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# Provides software support for floating point features if an FPU
# isn't present.
gcc_arm_none_cc_toolchain_import(
    name = "gcc",
    hdrs = glob([include + "/**/*" for include in LIBCC_INCLUDES]),
    includes = LIBC_INCLUDES,
    libname = "libgcc.a",
    libprefix = "lib/gcc/arm-none-eabi/10.3.1/thumb",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# libc_nano is a libc implementation that is developed under the
# newlib mingw project from RedHat. It has been designed for
# embedded systems.
gcc_arm_none_cc_toolchain_import(
    name = "c_nano",
    hdrs = glob([include + "/**/*.h" for include in LIBC_INCLUDES]),
    includes = LIBC_INCLUDES,
    libname = "libc_nano.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        ":math",
        ":system_calls",
        "@rules_cc_toolchain_config//:compiler_rt",
    ],
)

# Provides supplementary c++ library support. This should only be
# required if compiling with RTTI.
gcc_arm_none_cc_toolchain_import(
    name = "sup_cpp_nano",
    hdrs = glob([include + "/**/*" for include in LIBCC_INCLUDES]),
    includes = LIBC_INCLUDES + LIBCC_INCLUDES,
    libname = "libstdc++_nano.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# Provides semihosted system calls.
gcc_arm_none_cc_toolchain_import(
    name = "stdcpp_nano",
    hdrs = glob([include + "/**/*" for include in LIBCC_INCLUDES]),
    includes = LIBC_INCLUDES + LIBCC_INCLUDES,
    libname = "libstdc++_nano.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        ":sup_cpp_nano",
        "@rules_cc_toolchain_config//:libc",
    ],
)
