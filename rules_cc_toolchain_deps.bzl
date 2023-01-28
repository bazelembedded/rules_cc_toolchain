load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@rules_cc_toolchain//config:rules_cc_toolchain_config_repository.bzl", "rules_cc_toolchain_config")

def rules_cc_toolchain_deps():
    """Fetches the toolchain dependencies """

    # Setup latest version of Bazels platform repos. This should be called
    # before all other workspace deps.
    # Required by modules: cc_toolchain.
    # Required by: rules_cc_toolchain.
    if "platforms" not in native.existing_rules():
        http_archive(
            name = "platforms",
            sha256 = "5308fc1d8865406a49427ba24a9ab53087f17f5266a7aabbfc28823f3916e1ca",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
                "https://github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz",
            ],
        )

    # Setup clang compiler files.
    # Required by: rules_cc_toolchain.
    # Used by modules: cc_toolchain.
    if "clang_llvm_x86_64_linux_gnu_ubuntu" not in native.existing_rules():
        http_archive(
            name = "clang_llvm_x86_64_linux_gnu_ubuntu",
            url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz",
            sha256 = "38bc7f5563642e73e69ac5626724e206d6d539fbef653541b34cae0ba9c3f036",
            build_file = "@rules_cc_toolchain//third_party:clang_llvm_x86_64_linux_gnu_ubuntu.BUILD",
            strip_prefix = "clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04",
        )

    # Setup os normalisation tools.
    # Required by: rules_cc_toolchain.
    # Required by modules: cc_toolchain/internal/include_tools.
    if "rules_os" not in native.existing_rules():
        git_repository(
            name = "rules_os",
            commit = "68cdf228f8449a2b42b3a7b6d65395af74a007d7",
            remote = "https://github.com/silvergasp/rules_os.git",
        )

    # Setup x64 linux sysroot
    # Required by: rules_cc_toolchain, rules_cc_toolchain_config.
    # Required by modules: cc_toolchain.
    if "debian_stretch_amd64_sysroot" not in native.existing_rules():
        http_archive(
            name = "debian_stretch_amd64_sysroot",
            sha256 = "84656a6df544ecef62169cfe3ab6e41bb4346a62d3ba2a045dc5a0a2ecea94a3",
            urls = ["https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/2202c161310ffde63729f29d27fe7bb24a0bc540/debian_stretch_amd64_sysroot.tar.xz"],
            build_file = "@rules_cc_toolchain//third_party:debian_stretch_amd64_sysroot.BUILD",
        )

    # Setup rules_cc for toolchain rules.
    # Required by: rules_cc_toolchain.
    # Required by modeuls: cc_toolchain.
    if "rules_cc" not in native.existing_rules():
        http_archive(
            name = "rules_cc",
            urls = ["https://github.com/bazelbuild/rules_cc/archive/081771d4a0e9d7d3aa0eed2ef389fa4700dfb23e.zip"],
            sha256 = "68cece0593cca62ba7bcf47b6627f97d55fb9127041572767606f984c2c6ee9e",
            strip_prefix = "rules_cc-081771d4a0e9d7d3aa0eed2ef389fa4700dfb23e",
        )

    # Setup default configuration for toolchain.
    # Required by: rules_cc_toolchain.
    # Required by modules: third_party, cc_toolchain.
    if "rules_cc_toolchain_config" not in native.existing_rules():
        rules_cc_toolchain_config(
            name = "rules_cc_toolchain_config",
        )
