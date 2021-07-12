load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def test_repos():
    """ Pulls in dev dependencies to test the compiler against

    These dependencies are included for testing toolchains and are not required
    for general usage.
    """
    if "rules_python" not in native.existing_rules():
        http_archive(
            name = "rules_python",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.2.0/rules_python-0.2.0.tar.gz",
            sha256 = "778197e26c5fbeb07ac2a2c5ae405b30f6cb7ad1f5510ea6fdac03bded96cc6f",
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
            sha256 = "c6003e1d2e7fefa78a3039f19f383b4f3a61e81be8c19356f85b6461998ad3db",
            strip_prefix = "protobuf-3.17.3",
            urls = [
                "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/v3.17.3.tar.gz",
                "https://github.com/protocolbuffers/protobuf/archive/v3.17.3.tar.gz",
            ],
        )
