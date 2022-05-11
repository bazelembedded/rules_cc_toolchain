# rules_cc_toolchain
[![CI](https://github.com/silvergasp/bazel_rules_cc_toolchain/actions/workflows/blank.yml/badge.svg)](https://github.com/silvergasp/bazel_rules_cc_toolchain/actions/workflows/blank.yml)

An opinionated hermetic host toolchain for Bazel and C++. Currently this 
toolchain supports;
- Completely sandboxed linux builds (i.e. no system deps).
- Code coverage and combined lcov reports e.g.
  `bazel coverage //...`
- Static analysis (with clang-tidy). Read the
  [docs here](tools/clang_tidy/README.md).

The toolchain is modular enough that you should be able to BYO;
- Compiler and runtime
- libc
- libc++ / libc++abi
- Startup libraries (e.g. crt1.o)
- Injected toolchain headers and libs
## Getting Started
Add the following to your workspace file;

```py
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Set up host hermetic host toolchain.
git_repository(
    name = "rules_cc_toolchain",
    commit = "dd9265e3ce0daa444911040430bd716076869b34",
    remote = "https://github.com/silvergasp/rules_cc_toolchain.git",
)

load("@rules_cc_toolchain//:rules_cc_toolchain_deps.bzl", "rules_cc_toolchain_deps")

rules_cc_toolchain_deps()

load("@rules_cc_toolchain//cc_toolchain:cc_toolchain.bzl", "register_cc_toolchains")

register_cc_toolchains()
```

and the following to your '.bazelrc';

```
# Enforce strict checks of deprecated toolchain api.
build --incompatible_require_linker_input_cc_api

# Use new cc toolchain resolution api
build --incompatible_enable_cc_toolchain_resolution

# Enable transitions for toolchains. Required for ARM toolchain to work 
# correctly.
build --incompatible_override_toolchain_transition

# Code coverage support
coverage --combined_report=lcov
coverage --experimental_use_llvm_covmap
coverage --experimental_generate_llvm_lcov
coverage --incompatible_cc_coverage
```

## Defaults and config
This repository provides a set of sane defaults to make up a 
[complete toolchain](https://clang.llvm.org/docs/Toolchain.html). By default;

| Library           | Provider                                           |
| ----------------- | -------------------------------------------------- |
| libc              | Debian stretch sysroot (GNU glibc6)                |
| libc++            | LLVM 12.0.0 libc++                                 |
| libc++abi         | LLVM 12.0.0 libc++abi                              |
| libunwind         | Debian stretch sysroot (GNU gcc6 compiler runtime) |
| Startup Libraries | Debian stretch libcrt (GNU glibc6)                 |

This can be viewed in more detail by inspecting `//config/config:BUILD.bazel`.


## Bring your own system libraries (Advanced)
This toolchain supports bringing your own precompiled system libraries. 
Implementing this can be somewhat complicated and it is unlikely that we will
support specific combinations of libraries on request, although PR's here are 
welcome.

An example of how you might include your own version of libc++ is shown below.

Add a third_party dependency directory for your libc++ build definitions.
``` sh
mkdir third_party
touch third_party/clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04.BUILD
```

Add the following to your WORKSPACE file.
``` py
# WORKSPACE
http_archive(
    name = "clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04",
    build_file = "//third_party:clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04.BUILD",
    sha256 = "9694f4df031c614dbe59b8431f94c68631971ad44173eecc1ea1a9e8ee27b2a3",
    strip_prefix = "clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04",
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz",
)
```

From here you will need to add in your definitions that specify the library
files that are provided by this implementation of libc++.
``` py
# third_party:clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04.BUILD
load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

cc_toolchain_import(
    name = "llvm_libcxx",
    # All the headers to be included with this library
    hdrs = glob(["include/c++/v1/**"]),
    # It is common for a library e.g. libc++.so to actually just be a linker
    # script that points to a different library as is the case here where,
    # 'lib/libc++.so' is a linker script that points to 'lib/libc++.so.1'. 
    # This is done so that dynamic linker can ensure that it is linking 
    # against a compatible version of the library ABI (in this case version 1).
    additional_libs = [
        "lib/libc++.so.1",
    ],
    includes = ["include/c++/v1"],

    # NOTE: If one of static_library or shared_library is omitted this toolchain
    # will default to the other. This is useful if you want to static link a 
    # particular library. It is also possible to omit both static_library and 
    # shared_library, creating a header only toolchain lib.
    # Use with statically linkage.
    static_library = "lib/libc++.a",
    # Use with shared linkage.
    shared_library = "lib/libc++.so",

    # This is a usefult sanity check to say that this library can only be 
    # targetted at Linux on an x86 machine.
    target_compatible_with = select({
        "@platforms//os:linux": ["@platforms//cpu:x86_64"],
        "//conditions:default": ["@platforms//:incompatible"],
    }),

    # Here we make sure that this target is visible from the configuration layer.
    visibility = ["@rules_cc_toolchain_config//:__pkg__"],

    # This version of libc++ depends on libc and libunwind, by specifying the
    # dependency on the configuration layer rather than directly on the imported
    # library itself we can ensure that we can swap out the version of libc with
    # little effort. 
    deps = [
        "@rules_cc_toolchain_config//:libc",
        "@rules_cc_toolchain_config//:libunwind",
    ],
)
```

Now we can test the new toolchain to ensure that it functions correctly. 
``` sh
bazel coverage @rules_cc_toolchain//tests/... \
 --@rules_cc_toolchain_config//:libc++=@clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04//:llvm_libcxx
```

**NOTE:** While the toolchain itself is hermetic the runtime linkage is not in 
this example you will need to make sure that you have a recent version of LLVMs
libc++ installed on your system. If you would like to make sure that your
runtime is hermetic use the static linking mode in Bazel, or simply omit the 
shared_library attribute to disable shared linkage for that specific library.

You can also opt to make these changes permanent by overriding the
`rules_cc_toolchain_config` repository. e.g.

Copy this repositories `config/rules_cc_toolchain_config.BUILD` to your own
repository. You can now update the `build_setting_default` for `libc++` to point
to your implementation. To make this change final you can make use of the

```py
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04",
    build_file = "//third_party:clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04.BUILD",
    sha256 = "9694f4df031c614dbe59b8431f94c68631971ad44173eecc1ea1a9e8ee27b2a3",
    strip_prefix = "clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04",
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz",
)

# Set up host hermetic host toolchain.
git_repository(
    name = "rules_cc_toolchain",
    commit = "dd9265e3ce0daa444911040430bd716076869b34",
    remote = "https://github.com/silvergasp/rules_cc_toolchain.git",
)

# (NEW)
load("@rules_cc_toolchain//config:rules_cc_toolchain_config_repository.bzl", 
    "rules_cc_toolchain_config")

# (NEW) Must be called before rules_cc_toolchain_deps.
rules_cc_toolchain_config(
    name = "rules_cc_toolchain_config",
    build_file = "//config:rules_cc_toolchain_config.BUILD",
)

load("@rules_cc_toolchain//:rules_cc_toolchain_deps.bzl", "rules_cc_toolchain_deps")

rules_cc_toolchain_deps()

load("@rules_cc_toolchain//cc_toolchain:cc_toolchain.bzl", "register_cc_toolchains")

register_cc_toolchains() 
```
