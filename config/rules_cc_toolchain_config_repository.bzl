def _rules_cc_toolchain_config_impl(repository_ctx):
    repository_ctx.symlink(repository_ctx.attr.build_file, "BUILD")

rules_cc_toolchain_config = repository_rule(
    _rules_cc_toolchain_config_impl,
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            default = "@rules_cc_toolchain//config:rules_cc_toolchain_config.BUILD",
        ),
    },
)
