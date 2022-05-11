load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def test_repos():
    """ Pulls in dev dependencies to test the compiler against

    These dependencies are included for testing toolchains and are not required
    for general usage.
    """
    if "rules_python" not in native.existing_rules():
        http_archive(
            name = "rules_python",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.5.0/rules_python-0.5.0.tar.gz",
            sha256 = "cd6730ed53a002c56ce4e2f396ba3b3be262fd7cb68339f0377a45e8227fe332",
        )

    if "com_google_googletest" not in native.existing_rules():
        http_archive(
            name = "com_google_googletest",
            sha256 = "9dc9157a9a1551ec7a7e43daea9a694a0bb5fb8bec81235d8a1e6ef64c716dcb",
            strip_prefix = "googletest-release-1.10.0",
            urls = ["https://github.com/google/googletest/archive/release-1.10.0.tar.gz"],
        )

    if "com_github_google_benchmark" not in native.existing_rules():
        http_archive(
            name = "com_github_google_benchmark",
            sha256 = "3c6a165b6ecc948967a1ead710d4a181d7b0fbcaa183ef7ea84604994966221a",
            strip_prefix = "benchmark-1.5.0",
            urls = ["https://github.com/google/benchmark/archive/v1.5.0.tar.gz"],
        )

    if "com_google_absl" not in native.existing_rules():
        http_archive(
            name = "com_google_absl",
            sha256 = "0db0d26f43ba6806a8a3338da3e646bb581f0ca5359b3a201d8fb8e4752fd5f8",
            strip_prefix = "abseil-cpp-20200225.1",
            urls = ["https://github.com/abseil/abseil-cpp/archive/20200225.1.tar.gz"],
        )

    if "com_google_protobuf" not in native.existing_rules():
        http_archive(
            name = "com_google_protobuf",
            sha256 = "87407cd28e7a9c95d9f61a098a53cf031109d451a7763e7dd1253abf8b4df422",
            strip_prefix = "protobuf-3.19.1",
            urls = [
                "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/v3.19.1.tar.gz",
                "https://github.com/protocolbuffers/protobuf/archive/v3.19.1.tar.gz",
            ],
        )

    if "com_github_stmicroelectronics_stm32cubel4" not in native.existing_rules():
        git_repository(
            name = "com_github_stmicroelectronics_stm32cubel4",
            remote = "https://github.com/silvergasp/STM32CubeL4.git",
            commit = "44995541777cccba30d002f4e4578fca9c541c3f",
        )
