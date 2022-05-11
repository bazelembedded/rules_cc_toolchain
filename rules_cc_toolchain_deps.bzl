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
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
                "https://github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
            ],
            sha256 = "079945598e4b6cc075846f7fd6a9d0857c33a7afc0de868c2ccb96405225135d",
        )

    # Setup clang compiler files.
    # Required by: rules_cc_toolchain.
    # Used by modules: cc_toolchain.
    if "clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04" not in native.existing_rules():
        http_archive(
            name = "clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04",
            url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz",
            sha256 = "9694f4df031c614dbe59b8431f94c68631971ad44173eecc1ea1a9e8ee27b2a3",
            build_file = "@rules_cc_toolchain//third_party:clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04.BUILD",
            strip_prefix = "clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04",
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

    # Setup set of embedded platforms for toolchains.
    # Required by: rules_cc_toolchain.
    # Required by modules: cc_toolchain.
    if "embedded_platforms" not in native.existing_rules():
        git_repository(
            name = "embedded_platforms",
            remote = "https://github.com/silvergasp/embedded_platforms.git",
            commit = "350fc172ade372cd686bdaa45029b3103c74f13f",
            shallow_since = "1638948172 +0800",
        )

    # Set up newlib-nano libc and libstdc++, currently not using arm-none-eabi-gcc.
    # Required by: rules_cc_toolchain.
    # Required by modules: cc_toolchain.
    if "gcc_arm_none_eabi_10_3_2021_07_x86_64_linux" not in native.existing_rules():
        http_archive(
            name = "gcc_arm_none_eabi_10_3_2021_07_x86_64_linux",
            url = "https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2",
            sha256 = "97dbb4f019ad1650b732faffcc881689cedc14e2b7ee863d390e0a41ef16c9a3",
            build_file = "@rules_cc_toolchain//third_party:gcc_arm_none_eabi_10_3_2021_10_x86_64_linux.BUILD",
            strip_prefix = "gcc-arm-none-eabi-10.3-2021.10",
        )
