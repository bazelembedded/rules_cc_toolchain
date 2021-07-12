load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "feature",
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ACTION_NAME_GROUPS",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CPP_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
)
load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)

def _feature_impl(ctx):
    flag_sets = []
    if ctx.attr.cc_flags:
        flag_sets.append(flag_set(
            actions = ALL_CPP_COMPILE_ACTION_NAMES,
            flag_groups = [flag_group(flags = ctx.attr.cc_flags)],
        ))
    if ctx.attr.c_flags:
        flag_sets.append(flag_set(
            actions = [
                ACTION_NAMES.c_compile,
            ],
            flag_groups = [flag_group(flags = ctx.attr.c_flags)],
        ))
    if ctx.attr.compiler_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [flag_group(flags = ctx.attr.compiler_flags)],
        ))
    if ctx.attr.assembler_flags:
        flag_sets.append(flag_set(
            actions = [
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.assemble,
            ],
            flag_groups = [flag_group(flags = ctx.attr.assembler_flags)],
        ))
    if ctx.attr.linker_flags:
        flag_sets.append(flag_set(
            actions = ACTION_NAME_GROUPS.all_cc_link_actions,
            flag_groups = [flag_group(flags = ctx.attr.linker_flags)],
        ))
    if ctx.attr.strip_flags:
        flag_sets.append(flag_set(
            actions = [
                ACTION_NAMES.strip,
            ],
            flag_groups = [flag_group(flags = ctx.attr.strip_flags)],
        ))
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [label.name for label in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

cc_feature = rule(
    _feature_impl,
    attrs = {
        "enabled": attr.bool(
            default = False,
            doc = "This feature should be enabled by default",
        ),
        "provides": attr.string_list(
            default = [],
            doc = "Unique key for which only one provider of a functionality \
can be enabled any given time.",
        ),
        "implies": attr.label_list(
            default = [],
            doc = "Other features that are automatically enabled with this \
feature.",
        ),
        "cc_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when compiling c++ files.",
        ),
        "c_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when compiling c files.",
        ),
        "compiler_flags": attr.string_list(
            default = [],
            doc = "The list of flags to pass to the compiler regardless of if\
the target is a C or C++ library.",
        ),
        "assembler_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when assembling.",
        ),
        "linker_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when linking",
        ),
        "strip_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when stripping.",
        ),
    },
    provides = [FeatureInfo],
)

def _file_to_library_flag(file):
    lib_prefix = "lib"
    if file.basename.startswith(lib_prefix):
        library_name = file.basename.replace("." + file.extension, "")
        library_flag = "-l" + library_name[len(lib_prefix):]
    else:
        library_flag = file.path
    return library_flag

def _cc_toolchain_import_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]
    include_flags = [
        "-isystem" + inc
        for inc in toolchain_import_info
            .compilation_context.includes.to_list()
    ]

    injected_include_flags = [
        "-include " + hdr.path
        for hdr in toolchain_import_info
            .compilation_context
            .injected_headers
            .to_list()
    ]

    linker_runtime_path_flags = depset([
        "-Wl,-rpath," + path
        for path in toolchain_import_info
            .linking_context.runtime_paths.to_list()
    ]).to_list()

    linker_dir_flags = depset([
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    lib_prefix = "lib"
    linker_flags = depset([
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        _file_to_library_flag(file)
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ]).to_list()

    flag_sets = []
    if include_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = include_flags,
                ),
            ],
        ))

    if linker_dir_flags or linker_flags or linker_runtime_path_flags:
        flag_sets.append(flag_set(
            actions = CC_LINK_EXECUTABLE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = linker_dir_flags +
                            linker_flags +
                            linker_runtime_path_flags,
                ),
            ],
        ))

    library_feature = _feature(
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

def _sysroot_feature(ctx):
    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        implies = ["sysroot"] + [label.name for label in ctx.attr.implies],
        flag_sets = [
            flag_set(
                actions = CC_LINK_EXECUTABLE_ACTION_NAMES +
                          ALL_CC_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(
                        flags = [
                            "--sysroot",
                            ctx.attr.sysroot.label.workspace_root,
                        ],
                    ),
                ],
            ),
        ],
    )

cc_toolchain_sysroot_feature = rule(
    _sysroot_feature,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "sysroot": attr.label(mandatory = True),
    },
    provides = [FeatureInfo],
)
