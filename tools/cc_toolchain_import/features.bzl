load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "feature",
    "flag_group",
    "flag_set",
)
load(":defs.bzl", "CcToolchainImportInfo")
load(
    "@rules_cc//cc:action_names.bzl",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CC_LINK_ACTION_NAMES",
)

def _cc_toolchain_import_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]
    include_flags = [
        "-isystem" + inc
        for inc in toolchain_import_info
            .compilation_context.includes.to_list()
    ]

    linker_dir_flags = depset([
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    linker_flags = depset([
        "-l" + file.basename.replace("." + file.extension, "")
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        "-l" + file.basename.replace("." + file.extension, "")
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    flag_sets = []
    if include_flags:
        flag_sets.append(flag_set(
            actions = [ALL_CC_COMPILE_ACTION_NAMES],
            flag_groups = [
                flag_group(
                    flags = include_flags,
                ),
            ],
        ))

    if linker_dir_flags or linker_flags:
        flag_sets.append(flag_set(
            actions = [ALL_CC_LINK_ACTION_NAMES],
            flag_groups = [
                flag_group(
                    flags = linker_dir_flags + linker_flags,
                ),
            ],
        ))

    library_feature = feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        flag_sets = flag_sets,
        implies = ctx.attr.implies,
        provides = ctx.attr.provides,
    )
    return [library_feature, ctx.attr.toolchain_import[DefaultInfo]]

cc_toolchain_import_feature = rule(
    _cc_toolchain_import_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "toolchain_import": attr.label(providers = [CcToolchainImportInfo]),
    },
    provides = [FeatureInfo, DefaultInfo],
)
