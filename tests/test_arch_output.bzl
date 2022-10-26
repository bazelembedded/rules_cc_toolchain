load("//cc_toolchain/transitions:platform_transition.bzl", "build_for")

def correct_architecture_test(name, build_for_platform, target, llvm_architecture_info_contains, **kwargs):
    build_for(
        name = "__" + name,
        build_for_platform = build_for_platform,
        target = target,
    )

    native.sh_test(
        name = name,
        deps = ["@bazel_tools//tools/bash/runfiles"],
        data = ["@clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04//:bin/llvm-readelf", ":__" + name],
        srcs = ["test_arch_output.sh"],
        args = ["$(location :__{})".format(name)] +
               ["\"{}\"".format(s) for s in llvm_architecture_info_contains],
        **kwargs
    )
