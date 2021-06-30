load(
    "@rules_cc_toolchain//tools/cc_toolchain_import:defs.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_cc_toolchain//tools/cc_toolchain_import:features.bzl",
    "cc_toolchain_import_feature",
)

filegroup(
    name = "all",
    srcs = glob(["**/*"]),
)

cc_toolchain_import(
    name = "llvm_libunwind",
    hdrs = ["lib/clang/12.0.0/include/unwind.h"],
    includes = ["lib/clang/12.0.0/include"],
    shared_library = "lib/libunwind.so",
    static_library = "lib/libunwind.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        "@rules_cc_toolchain_config//:libc",
    ],
)

cc_toolchain_import_feature(
    name = "libunwind",
    enabled = True,
    provides = ["libunwind"],
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    toolchain_import = ":llvm_libunwind",
)

cc_toolchain_import(
    name = "llvm_libcxx",
    hdrs = glob(["include/c++/v1/**"]),
    includes = ["include/c++/v1"],
    shared_library = "lib/libc++.so",
    static_library = "lib/libc++.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        "@rules_cc_toolchain_config//:libc",
        "@rules_cc_toolchain_config//:libunwind",
    ],
)

cc_toolchain_import_feature(
    name = "libc++",
    enabled = True,
    provides = ["libc++"],
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    toolchain_import = ":llvm_libcxx",
)

cc_toolchain_import(
    name = "llvm_libclang_rt",
    includes = ["lib/clang/12.0.0"],
    static_library = "lib/clang/12.0.0/lib/linux/libclang_rt.builtins-x86_64.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

cc_toolchain_import_feature(
    name = "compiler_rt",
    enabled = True,
    provides = ["libc++"],
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    toolchain_import = ":llvm_libclang_rt",
)

# TODO: Sanitize runtime libraries.
