def _platform_transition_impl(settings, attr):
    _ignore = settings
    return {"//command_line_option:platforms": attr.build_for_platform}

platform_transition = transition(
    implementation = _platform_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)

def _build_for(ctx):
    executable = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.symlink(output = executable, target_file = ctx.file.target)
    return [DefaultInfo(executable = executable)]

build_for = rule(
    implementation = _build_for,
    attrs = {
        "build_for_platform": attr.string(mandatory = True),
        "target": attr.label(mandatory = True, allow_single_file = True, cfg = platform_transition),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
)
