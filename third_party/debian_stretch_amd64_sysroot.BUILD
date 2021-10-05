load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)
load(
    "@rules_cc_toolchain//cc_toolchain:sysroot.bzl",
    "sysroot_package",
)

sysroot_package(
    name = "sysroot",
    visibility = ["//visibility:public"],
)

INCLUDES = [
    "usr/local/include",
    "usr/include/x86_64-linux-gnu",
    "usr/include",
]

CRT_OBJECTS = [
    "crt1",
    "crti",
    "crtn",
]

[
    cc_toolchain_import(
        name = obj,
        static_library = "usr/lib/x86_64-linux-gnu/%s.o" % obj,
    )
    for obj in CRT_OBJECTS
]

cc_toolchain_import(
    name = "startup_libs",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [":" + obj for obj in CRT_OBJECTS],
)

cc_toolchain_import(
    name = "gcc",
    additional_libs = ["usr/lib/gcc/x86_64-linux-gnu/6/libgcc_s.so.1"],
    runtime_path = "/usr/lib/x86_64-linux-gnu",
    shared_library = "usr/lib/gcc/x86_64-linux-gnu/6/libgcc_s.so",
    static_library = "usr/lib/gcc/x86_64-linux-gnu/6/libgcc.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
)

cc_toolchain_import(
    name = "mvec",
    additional_libs = [
        "usr/lib/x86_64-linux-gnu/libmvec_nonshared.a",
        "lib/x86_64-linux-gnu/libmvec.so.1",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libmvec.so",
    static_library = "usr/lib/x86_64-linux-gnu/libmvec.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)

cc_toolchain_import(
    name = "dynamic_linker",
    additional_libs = ["lib/x86_64-linux-gnu/ld-linux-x86-64.so.2"],
    shared_library = "usr/lib/x86_64-linux-gnu/libdl.so",
    static_library = "usr/lib/x86_64-linux-gnu/libdl.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)

cc_toolchain_import(
    name = "math",
    additional_libs = [
        "lib/x86_64-linux-gnu/libm.so.6",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libm.so",
    static_library = "usr/lib/x86_64-linux-gnu/libm.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)

cc_toolchain_import(
    name = "pthread",
    additional_libs = [
        "usr/lib/x86_64-linux-gnu/libpthread_nonshared.a",
        "lib/x86_64-linux-gnu/libpthread.so.0",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/libpthread.so",
    static_library = "usr/lib/x86_64-linux-gnu/libpthread.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    deps = [":rt"],
)

cc_toolchain_import(
    name = "rt",
    additional_libs = [
        "lib/x86_64-linux-gnu/librt.so.1",
        "lib/x86_64-linux-gnu/librt-2.24.so",
    ],
    shared_library = "usr/lib/x86_64-linux-gnu/librt.so",
    static_library = "usr/lib/x86_64-linux-gnu/librt.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)

cc_toolchain_import(
    name = "glibc",
    hdrs = glob([inc + "/**/*.h" for inc in INCLUDES] + [inc + "/*.h" for inc in INCLUDES]),
    additional_libs = [
        "lib/x86_64-linux-gnu/libc.so.6",
        "usr/lib/x86_64-linux-gnu/libc_nonshared.a",
    ],
    includes = INCLUDES,
    shared_library = "usr/lib/x86_64-linux-gnu/libc.so",
    static_library = "usr/lib/x86_64-linux-gnu/libc.a",
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
    visibility = ["@rules_cc_toolchain//config:__pkg__"],
    deps = [
        ":dynamic_linker",
        ":gcc",
        ":math",
        ":mvec",
        ":pthread",
        "@rules_cc_toolchain_config//:compiler_rt",
    ],
)
