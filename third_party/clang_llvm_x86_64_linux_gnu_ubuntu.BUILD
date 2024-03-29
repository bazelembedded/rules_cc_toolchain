load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

exports_files(glob(["bin/*"]))

CLANG_VERSION = "15.0.6"

filegroup(
    name = "all",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar_files",
    srcs = ["bin/llvm-ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "compiler_files",
    srcs = [
        "bin/clang",
        "bin/clang++",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "linker_files",
    srcs = [
        "bin/ld.lld",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy_files",
    srcs = ["bin/llvm-objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip_files",
    srcs = ["bin/llvm-strip"],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "llvm_libunwind",
    hdrs = glob(["lib/clang/*/include/unwind.h"]),
    includes = ["lib/clang/{clang_version}/include".format(clang_version = CLANG_VERSION)],
    runtime_path = "/usr/lib/x86_64-linux-gnu",
    shared_library = "lib/libunwind.so",
    static_library = "lib/x86_64-unknown-linux-gnu/libunwind.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        "@rules_cc_toolchain_config//:libc",
    ],
)

cc_toolchain_import(
    name = "llvm_libcxx",
    hdrs = glob(["include/c++/v1/**"]),
    includes = ["include/c++/v1"],
    static_library = "lib/x86_64-unknown-linux-gnu/libc++.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        "@rules_cc_toolchain_config//:libc",
        "@rules_cc_toolchain_config//:libunwind",
        "@rules_cc_toolchain_config//:llvm_config_site",
    ],
)

cc_toolchain_import(
    name = "llvm_config_site",
    hdrs = ["include/x86_64-unknown-linux-gnu/c++/v1/__config_site"],
    includes = ["include/x86_64-unknown-linux-gnu/c++/v1"],
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

cc_toolchain_import(
    name = "llvm_libcxx_abi",
    hdrs = glob(["include/c++/v1/**"]),
    includes = ["include/c++/v1"],
    static_library = "lib/x86_64-unknown-linux-gnu/libc++abi.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        "@rules_cc_toolchain_config//:libc",
        "@rules_cc_toolchain_config//:libpthread",
    ],
)

cc_toolchain_import(
    name = "llvm_libclang_rt",
    hdrs = glob([
        "lib/clang/*/*.h",
        "lib/clang/*/include/*.h",
        "lib/clang/*/include/**/*.h",
    ]),
    includes = [
        "lib/clang/{clang_version}".format(clang_version = CLANG_VERSION),
        "lib/clang/{clang_version}/include".format(clang_version = CLANG_VERSION),
    ],
    static_library = "lib/clang/{clang_version}/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a".format(clang_version = CLANG_VERSION),
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

# TODO: Sanitize runtime libraries.
