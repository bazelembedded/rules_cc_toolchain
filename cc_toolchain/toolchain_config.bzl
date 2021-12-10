load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "action_config",
    "env_entry",
    "env_set",
    "feature",
    "tool",
    "tool_path",
)
load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ACTION_NAME_GROUPS",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "LLVM_COV")

ALL_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.lto_indexing,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.strip,
    ACTION_NAMES.objc_archive,
    ACTION_NAMES.objc_compile,
    ACTION_NAMES.objc_executable,
    ACTION_NAMES.objc_fully_link,
    ACTION_NAMES.objcpp_compile,
    ACTION_NAMES.objcpp_executable,
    ACTION_NAMES.clif_match,
    LLVM_COV,
]

def _label_to_tool_path_feature(tool_mapping = {}):
    """Creates a feature with an env variable pointing to the label.

    Creates an always enabled feature that sets an environment variable in the
    format '<name:capitalised>_TOOL_PATH'. This can then be used by the
    execution wrapper, which has to remain relative to the toolchain
    instantiation.

    Args:
        tool_mapping (Dict[str,File]): A mapping between the tool name and the
            executable file for that tool.
    """
    return feature(
        name = "__tool_paths_as_environment_vars",
        enabled = True,
        env_sets = [env_set(
            # All relevant actions.
            actions = ALL_ACTIONS,
            env_entries = [
                env_entry(name.upper() + "_TOOL_PATH", file.path)
                for name, file in tool_mapping.items()
                if file
            ],
        )],
    )

def _impl(ctx):
    action_configs = [action_config(
        action_name = action,
        enabled = True,
        tools = [
            tool(ctx.attr._tool_paths["ld"]),
        ],
        implies = [
        ],
    ) for action in ACTION_NAME_GROUPS.all_cc_link_actions]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "unknown",
        host_system_name = "unknown",
        target_system_name = "unknown",
        target_cpu = "unknown",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = [
            tool_path(name = name, path = path)
            for name, path in ctx.attr._tool_paths.items()
        ],
        features = [
            label[FeatureInfo]
            for label in ctx.attr.compiler_features
        ] + [_label_to_tool_path_feature({
            "gcc": ctx.file.c_compiler,
            "cpp": ctx.file.cc_compiler,
            "ld": ctx.file.linker,
            "ar": ctx.file.archiver,
            "gcov": ctx.file.test_coverage_tool,
            "llvm-cov": ctx.file.binary_coverage_tool,
            "nm": ctx.file.symbol_list_tool,
            "objdump": ctx.file.object_dump_tool,
            "strip": ctx.file.strip_tool,
        })],
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "_tool_paths": attr.string_dict(
            default = {
                "gcc": "wrappers/posix/gcc",
                "cpp": "wrappers/posix/cpp",
                "ld": "wrappers/posix/ld",
                "ar": "wrappers/posix/ar",
                "gcov": "wrappers/posix/gcov",
                "llvm-cov": "wrappers/posix/llvm-cov",
                "nm": "wrappers/posix/nm",
                "objdump": "wrappers/posix/objdump",
                "strip": "wrappers/posix/strip",
            },
        ),
        "compiler_features": attr.label_list(
            providers = [FeatureInfo],
            doc = "A list of features that are used by the toolchain.",
            mandatory = True,
            cfg = "target",
        ),
        "c_compiler": attr.label(
            doc = "The c compiler e.g. clang/gcc. Maps to tool path 'gcc'.",
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "cc_compiler": attr.label(
            doc = "The c++ compiler e.g. clang/gcc. Maps to tool path 'cpp'.",
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "linker": attr.label(
            doc = "The linker e.g. ld/lld. Maps to tool path 'ld'.",
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "archiver": attr.label(
            doc = "The archiver e.g. ar/llvm-ar. Maps to tool path 'ar'.",
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "test_coverage_tool": attr.label(
            doc = "The test coverage tool e.g. gcov/llvm-profdata.\
 Maps to tool path 'gcov'.",
            allow_single_file = True,
            cfg = "exec",
        ),
        "binary_coverage_tool": attr.label(
            doc = "The binary test coverage tool e.g. llvm-cov. Maps to tool \
path 'llvm-cov'.",
            allow_single_file = True,
            cfg = "exec",
        ),
        "symbol_list_tool": attr.label(
            doc = "The symbol list tool e.g. nm. Maps to tool path 'nm'.",
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "object_dump_tool": attr.label(
            doc = "The object dump tool e.g. objdump. Maps to tool path \
'objdump'.",
            cfg = "exec",
            allow_single_file = True,
            mandatory = True,
        ),
        "strip_tool": attr.label(
            doc = "The strip tool e.g. strip. Maps to tool path 'strip'.",
            allow_single_file = True,
            cfg = "exec",
        ),
    },
    provides = [CcToolchainConfigInfo],
)
