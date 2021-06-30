load(
    "@rules_cc_toolchain//tools/cc_toolchain_import:defs.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_cc_toolchain//tools/cc_toolchain_import:features.bzl",
    "cc_toolchain_import_feature",
)

INCLUDES = [
    "usr/include",
    "usr/include/x86_64-linux-gnu",
    "usr/lib/gcc/x86_64-linux-gnu/9/include",
    "usr/local/include",
]

cc_toolchain_import(
    name = "glibc",
    hdrs = glob([inc + "/*.h" for inc in INCLUDES]),
    includes = INCLUDES,
    shared_library = "usr/lib/x86_64-linux-gnu/libc.so",
    static_library = "usr/lib/x86_64-linux-gnu/libc.a",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

cc_toolchain_import_feature(
    name = "libc",
    enabled = True,
    provides = ["libc"],
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    toolchain_import = ":glibc",
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)
