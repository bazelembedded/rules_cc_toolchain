# Clang tidy 
This toolchain suite ships with a set of tools to download and integrate
clang-tidy into your build. To integrate this into your build you may either use
the default configuration that ships with clang-tidy-12 or configure your
repository.

## Getting started
To make use of the default configuration for clang-tidy you can simply compile
with the command line flags as shown below.

```sh
bazel build //your:target --aspects \
  @rules_cc_toolchain//tools/clang_tidy:clang_tidy.bzl%clang_tidy_aspect \
  --output_groups=report 
```

## Specifying your own clang-tidy configuration
You will need to create a `.clang-tidy` config file somewhere in your
repository. In contrast to the
[clang tidy docs](https://clang.llvm.org/extra/clang-tidy) this file can be
anywhere in your repository. This can be useful if you would like define and
then switch between multiple analysis configs.

### Example
First create your custom `.clang-tidy` config file;
```yaml
# //static_analysis:.clang-tidy
# Use all built in checks provided by the clang toolchain.
Checks: 'clang-diagnostic-*,clang-analyzer-*'
# Treat all warnings as errors. 
WarningsAsErrors: '*'
```

Now create a `BUILD.bazel` file in the same directory to create your build
config.
```py
# //static_analysis:BUILD.bazel
load("@rules_cc_toolchain/tools/clang_tidy:clang_tidy.bzl", 
  "clang_tidy_config")

clang_tidy_config(
    name = "my_custom_config",
    config = ".clang-tidy",
    visibility = ["//visibility:public"],
)
```

You can now override the default configuration for this repository by adding the
flags as follows.
```sh
bazel build //your:target --aspects \
  @rules_cc_toolchain//tools/clang_tidy:clang_tidy.bzl%clang_tidy_aspect \
  --output_groups=report \
  --@rules_cc_toolchain_config//:clang_tidy_config=\
  //static_analysis:clang_tidy_config
```

For conveniance this can be shortened by adding the following lines to your
`.bazelrc`.
```
# //:.bazelrc
# ...
# Configures static analyser.
build:analyser --aspects @rules_cc_toolchain//tools/clang_tidy:clang_tidy.bzl%clang_tidy_aspect  
build:analyser --output_groups=report
build --@rules_cc_toolchain_config//:clang_tidy_config=@trackalab//:clang_tidy_config
```

This then reduces the build command to;

`bazel build //your:target --config analyser`