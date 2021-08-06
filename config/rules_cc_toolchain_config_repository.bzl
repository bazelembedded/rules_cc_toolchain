def _rules_cc_toolchain_config_impl(repository_ctx):
    repository_ctx.symlink(repository_ctx.attr.build_file, "BUILD")

rules_cc_toolchain_config = repository_rule(
    _rules_cc_toolchain_config_impl,
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            default = "@rules_cc_toolchain//config:rules_cc_toolchain_config.BUILD",
            doc = "The build file containing the configurations for this toolchain.",
        ),
    },
    doc = """
A toolchain configuration.

To override the default configuration use this rule before calling `rules_cc_toolchain_deps`.

Example:
```python
load("@rules_cc_toolchain//config:rules_cc_toolchain_config_repository.bzl", 
    "rules_cc_toolchain_config")

rules_cc_toolchain_config(
    name = "rules_cc_toolchain_config",
    build_file = "@my_workspace//config:my_config.BUILD",
)

load("//:rules_cc_toolchain_deps.bzl", "rules_cc_toolchain_deps")

# Must be called after rules_cc_toolchain_config rule to successfully override 
# the configuration.
rules_cc_toolchain_deps()
```
""",
)
