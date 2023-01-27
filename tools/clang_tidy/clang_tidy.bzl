load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")
load(
    "@rules_cc//cc:action_names.bzl",
    "CPP_COMPILE_ACTION_NAME",
    "C_COMPILE_ACTION_NAME",
)

ClangTidyConfigInfo = provider(
    "The config information for clang-tidy.",
    fields = ["config"],
)

def _language(file):
    """ Returns the language for the file

    Args:
        file (File): The file to get the language for
    """
    if file.extension == "c":
        return "c"
    else:
        return "cc"

def _is_src(file):
    """ Returns true if the file is a source file

    Bazel allows for headers in the srcs attributes, we need to filter them out.

    Args:
        file (File): The file to check.
"""
    if file.extension in ["c", "cc", "cpp", "cxx", "C", "c++", "C++"] and \
       file.is_source:
        return True
    return False

def _run_clang_tidy(
        target,
        ctx,
        file,
        clang_tidy_config,
        compilation_action_name,
        user_compile_flags):
    """ Runs clang-tidy on a given translation unit

    Args:
        target (Target): The target currently being built.
        ctx (Context): The current build context.
        file (File): The source file to run clang-tidy on.
        clang_tidy_config (File): The configuration to use.
        compilation_action_name (str): The name of the compilation action.
        user_compile_flags (List): The user-specified flags to use.

    Returns:
        A report file for the given translation unit.
    """
    cc_toolchain = find_cc_toolchain(ctx)

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    compilation_context = target[CcInfo].compilation_context
    cc_compile_variables = cc_common.create_compile_variables(
        user_compile_flags = user_compile_flags,
        source_file = file.path,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        include_directories = compilation_context.includes,
        quote_include_directories = compilation_context.quote_includes,
        system_include_directories = compilation_context.system_includes,
        framework_include_directories = compilation_context.framework_includes,
        preprocessor_defines = compilation_context.defines,
    )
    cc_compile_command_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = compilation_action_name,
        variables = cc_compile_variables,
    )
    report = ctx.actions.declare_file(ctx.rule.attr.name +
                                      file.short_path.replace(".", "_") +
                                      ".clang_tidy_report")

    ctx.actions.run_shell(
        outputs = [report],
        inputs = depset(
            [file, clang_tidy_config],
            transitive = [cc_toolchain.all_files, compilation_context.headers],
        ),
        mnemonic = "ClangTidy",
        progress_message = "Analysing {}.".format(file.path),
        arguments = [file.path, "--export-fixes", report.path, "--"] +
                    cc_compile_command_line,
        # Clang tidy does not output a fix if the file is already clean.
        # Bazel requires and output file, so we touch the output first.
        command = "cp {clang_tidy_config} .clang-tidy && \
             touch {report_path} && \
            {clang_tidy} $@".format(
            clang_tidy_config = clang_tidy_config.path,
            report_path = report.path,
            clang_tidy = ctx.executable._clang_tidy.path,
        ),
        tools = [ctx.executable._clang_tidy],
    )
    return report

def _clang_tidy_aspect_impl(target, ctx):
    # Ignore targets that are not C++
    if not CcInfo in target:
        return []
    clang_tidy_config = ctx.actions.declare_file(".clang-tidy")
    ctx.actions.symlink(
        output = clang_tidy_config,
        target_file = ctx.attr._config[ClangTidyConfigInfo].config,
    )

    if hasattr(ctx.rule.attr, "srcs"):
        srcs = [src for src in ctx.rule.files.srcs if _is_src(src)]
    else:
        srcs = []

    if hasattr(ctx.rule.attr, "copts"):
        user_compile_flags = ctx.rule.attr.copts
    else:
        user_compile_flags = []

    reports = []
    for src in [src for src in srcs if _language(src) == "cc"]:
        reports.append(_run_clang_tidy(
            target,
            ctx,
            src,
            clang_tidy_config,
            CPP_COMPILE_ACTION_NAME,
            ctx.fragments.cpp.cxxopts +
            ctx.fragments.cpp.copts +
            user_compile_flags,
        ))
    for src in [src for src in srcs if _language(src) == "c"]:
        reports.append(_run_clang_tidy(
            target,
            ctx,
            src,
            clang_tidy_config,
            C_COMPILE_ACTION_NAME,
            ctx.fragments.cpp.conlyopts + user_compile_flags,
        ))

    return [OutputGroupInfo(report = depset(reports))]

clang_tidy_aspect = aspect(
    _clang_tidy_aspect_impl,
    fragments = ["cpp"],
    attrs = {
        "_clang_tidy": attr.label(
            allow_single_file = True,
            default = "@clang_llvm_x86_64_linux_gnu_ubuntu//:bin/clang-tidy",
            cfg = "exec",
            executable = True,
        ),
        "_config": attr.label(
            default = "@rules_cc_toolchain_config//:clang_tidy_config",
            providers = [ClangTidyConfigInfo],
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    doc = """
Runs clang-tidy on the given C++ sources

This aspect runs clang-tidy on the given set of c/c++ sources. You can use this aspect
by running;
``` sh
bazel build //my:target \\ 
    --aspects build_bazel_rules_cc//cc:clang_tidy:clang_tidy.bzl%clang_tidy_aspect
```

You can override the default configuration by using the clang_tidy_config rule. e.g.
```py
# //BUILD.bazel
cc_toolchain_config(
    name = "my_config",
    config = ".clang-tidy",
)
```
The passing in a command line flag to point the aspect at your new config rule e.g.
``` sh
bazel build //my:target \\ 
    --aspects @build_bazel_rules_cc//cc:clang_tidy:clang_tidy.bzl%clang_tidy_aspect \\
    --@rules_cc_toolchain_config//:clang_tidy_config=//:my_config
```
    
In most cases it is likely that you will want to shorten the command line flags using 
your .bazelrc file. e.g.
```
# //.bazelrc
build:analyze --aspects @build_bazel_rules_cc//cc:clang_tidy:clang_tidy.bzl%clang_tidy_aspect
build:analyze --@rules_cc_toolchain_config//:clang_tidy_config=//:my_config
```

You can then run the analysis using the following command;
``` sh
bazel build //my:target --config analyze
```

""",
)

def _clang_tidy_config_impl(ctx):
    return [ClangTidyConfigInfo(config = ctx.file.config)]

clang_tidy_config = rule(
    _clang_tidy_config_impl,
    attrs = {
        "config": attr.label(
            allow_single_file = [".clang-tidy"],
            mandatory = True,
            doc = "Clang tidy config file.",
        ),
    },
    provides = [ClangTidyConfigInfo],
)
