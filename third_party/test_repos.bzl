load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

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

    if "com_googlesource_code_re2" not in native.existing_rules():
        # Dependency of googletest
        http_archive(
            name = "com_googlesource_code_re2",  # 2022-12-21T14:29:10Z
            sha256 = "b9ce3a51beebb38534d11d40f8928d40509b9e18a735f6a4a97ad3d014c87cb5",
            strip_prefix = "re2-d0b1f8f2ecc2ea74956c7608b6f915175314ff0e",
            urls = ["https://github.com/google/re2/archive/d0b1f8f2ecc2ea74956c7608b6f915175314ff0e.zip"],
        )

    if "com_google_googletest" not in native.existing_rules():
        http_archive(
            name = "com_google_googletest",
            sha256 = "564f89e499a99e85a481122d22b2e3e7a8f6e8b8809a64363f96edd2b2ee2979",
            strip_prefix = "googletest-1.12.0",
            urls = [
                "https://github.com/google/googletest/archive/refs/tags/v1.12.0.tar.gz",
            ],
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
            sha256 = "3ea49a7d97421b88a8c48a0de16c16048e17725c7ec0f1d3ea2683a2a75adc21",
            strip_prefix = "abseil-cpp-20230125.0",
            urls = ["https://github.com/abseil/abseil-cpp/archive/refs/tags/20230125.0.tar.gz"],
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
