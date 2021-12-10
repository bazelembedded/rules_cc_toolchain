workspace(
    name = "rules_cc_toolchain",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("//:rules_cc_toolchain_deps.bzl", "rules_cc_toolchain_deps")

# Setups up Bazels starlark libraries and utilities.
# Required by: rules_cc_toolchain.
# Required by modules: tools.
http_archive(
    name = "bazel_skylib",
    sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

rules_cc_toolchain_deps()

register_execution_platforms("@rules_cc_toolchain//tests/...")

register_toolchains("@rules_cc_toolchain//cc_toolchain/...")

# Sets up Bazels documentation generator.
# Required by: rules_cc_toolchain.
# Required by modules: All
git_repository(
    name = "io_bazel_stardoc",
    commit = "8f6d22452d088b49b13ba2c224af69ccc8ccbc90",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1620849756 -0400",
)

# Sets up Bazels packaging rules, for use the document generator.
# Required by: rules_cc_toolchain.
# Required by modules: All
http_archive(
    name = "rules_pkg",
    sha256 = "a89e203d3cf264e564fcb96b6e06dd70bc0557356eb48400ce4b5d97c2c3720d",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
    ],
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()

load("//third_party:test_repos.bzl", "test_repos")

# Pull in a set of well known repositories for testing the toolchains against.
# Required by: None (Usage in CI + presubmit only).
# Used by modules: None.
test_repos()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
