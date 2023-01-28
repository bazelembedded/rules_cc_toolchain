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
    name = "bazel_skylib",  # 2022-09-01
    sha256 = "4756ab3ec46d94d99e5ed685d2d24aece484015e45af303eb3a11cab3cdc2e71",
    strip_prefix = "bazel-skylib-1.3.0",
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/refs/tags/1.3.0.zip"],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

rules_cc_toolchain_deps()

register_toolchains("//cc_toolchain/...")

# Sets up Bazels documentation generator.
# Required by: rules_cc_toolchain.
# Required by modules: All
git_repository(
    name = "io_bazel_stardoc",
    commit = "8f6d22452d088b49b13ba2c224af69ccc8ccbc90",
    remote = "https://github.com/bazelbuild/stardoc.git",
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
