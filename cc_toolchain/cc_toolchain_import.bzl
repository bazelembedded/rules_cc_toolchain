LinkingContextInfo = provider(
    fields = {
        "dynamic_libraries": "The shared library file.",
        "static_libraries": "The static library file.",
        "runtime_paths": "The directory to search for shared libs at runtime.",
        "additional_libs": "Additional files required for linking.",
    },
    doc = "The linking context for a precompiled toolchain library.",
)

CompilationContextInfo = provider(
    fields = {
        "headers": "Depset of headers that make up this lib.",
        "injected_headers": "The set of headers that are injected into every\
compilation unit e.g. using -include.",
        "includes": "A depset of includes that configure this lib.",
    },
    doc = "The headers and includes that make up a lib.",
)

CcToolchainImportInfo = provider(
    fields = {
        "linking_context": "The linking context to be used with the toolchain.",
        "compilation_context": "The compilation files to be included in the \
toolchain.",
    },
    doc = "Provides info for library files to be included as part of the\
 toolchain e.g. libc, libstdc++ etc.",
)

def _linking_context(
        dynamic_library,
        static_library,
        runtime_path,
        additional_libs):
    return LinkingContextInfo(
        dynamic_libraries = dynamic_library,
        static_libraries = static_library,
        runtime_paths = runtime_path,
        additional_libs = additional_libs,
    )

def _compilation_ctx(headers, injected_headers, includes):
    return CompilationContextInfo(
        headers = headers,
        includes = includes,
        injected_headers = injected_headers,
    )

def _cc_toolchain_import(compilation_context, linking_context):
    return CcToolchainImportInfo(
        compilation_context = compilation_context,
        linking_context = linking_context,
    )

def _normalise_include(ctx, inc):
    root_str = ""
    if ctx.label.workspace_root:
        root_str = ctx.label.workspace_root + "/"
    package_str = ""
    if ctx.label.package:
        package_str = ctx.label.package + "/"
    return root_str + package_str + inc

def _cc_toolchain_import_impl(ctx):
    deps = ctx.attr.deps
    transitive_hdrs = []
    transitive_shared_libraries = []
    transitive_static_libraries = []
    transitive_includes = []
    transitive_runtime_paths = []
    transitive_additional_libs = []
    transitive_injected_hdrs = []
    if deps:
        transitive_hdrs = [
            dep[CcToolchainImportInfo].compilation_context.headers
            for dep in deps
        ]
        transitive_injected_hdrs = [
            dep[CcToolchainImportInfo].compilation_context.injected_headers
            for dep in deps
        ]
        transitive_shared_libraries = [
            dep[CcToolchainImportInfo].linking_context.dynamic_libraries
            for dep in deps
        ]
        transitive_static_libraries = [
            dep[CcToolchainImportInfo].linking_context.static_libraries
            for dep in deps
        ]
        transitive_includes = [
            dep[CcToolchainImportInfo].compilation_context.includes
            for dep in deps
        ]
        transitive_runtime_paths = [
            dep[CcToolchainImportInfo].linking_context.runtime_paths
            for dep in deps
        ]
        transitive_additional_libs = [
            dep[CcToolchainImportInfo].linking_context.additional_libs
            for dep in deps
        ]
    if not ctx.attr.includes:
        includes = []
    else:
        includes = ctx.attr.includes

    compilation_context = _compilation_ctx(
        depset(ctx.files.hdrs, transitive = transitive_hdrs),
        depset(ctx.files.injected_hdrs, transitive = transitive_injected_hdrs),
        depset(
            [_normalise_include(ctx, inc) for inc in includes],
            transitive = transitive_includes,
            # Ensures that deps further down the tree are included last on the
            # command line. This is important to insure that #inlcude_next
            # works as expected.
            order = "topological",
        ),
    )

    if ctx.file.shared_library:
        shared_library_list = [ctx.file.shared_library]
    else:
        shared_library_list = []

    if ctx.file.static_library:
        static_library_list = [ctx.file.static_library]
    else:
        static_library_list = []

    if ctx.attr.runtime_path:
        runtime_paths = [ctx.attr.runtime_path]
    else:
        runtime_paths = []

    linking_context = _linking_context(
        depset(
            shared_library_list,
            transitive = transitive_shared_libraries,
            order = "topological",
        ),
        depset(
            static_library_list,
            transitive = transitive_static_libraries,
            order = "topological",
        ),
        depset(
            runtime_paths,
            transitive = transitive_runtime_paths,
            order = "topological",
        ),
        depset(
            ctx.files.additional_libs,
            transitive = transitive_additional_libs,
            order = "topological",
        ),
    )
    library_files = []
    if ctx.file.static_library:
        library_files.append(ctx.file.static_library)
    if ctx.file.shared_library:
        library_files.append(ctx.file.shared_library)

    result = [
        DefaultInfo(files =
                        depset(
                            ctx.files.hdrs +
                            ctx.files.injected_hdrs +
                            library_files +
                            ctx.files.additional_libs,
                            transitive = transitive_static_libraries +
                                         transitive_shared_libraries +
                                         transitive_hdrs +
                                         transitive_additional_libs +
                                         transitive_injected_hdrs,
                            order = "topological",
                        )),
        _cc_toolchain_import(compilation_context, linking_context),
    ]
    return result

cc_toolchain_import = rule(
    _cc_toolchain_import_impl,
    attrs = {
        "hdrs": attr.label_list(
            doc = "List of headers.",
            allow_files = True,
            default = [],
        ),
        "injected_hdrs": attr.label_list(
            doc = "The list of headers to inject into the toolchain e.g.\
-include.",
            allow_files = True,
            default = [],
        ),
        "includes": attr.string_list(
            doc = "List of includes to apply to the headers",
            default = [],
        ),
        "static_library": attr.label(
            doc = "The precompiled static library.",
            allow_single_file = [".a", ".pic.a", ".lib", ".o"],
        ),
        "shared_library": attr.label(
            doc = "The precompiled shared library.",
            allow_single_file = [".so", ".dll", ".dylib"],
        ),
        "additional_libs": attr.label_list(
            doc = "Additional files that are needed to link this library.\
e.g. libgcc_s.so requires libgcc_s.so.1",
            allow_files = True,
            default = [],
        ),
        "runtime_path": attr.string(
            doc = "The runtime path to search for shared libraries",
        ),
        "deps": attr.label_list(
            doc = "Toolchain libraries that this library depends on.",
            default = [],
        ),
    },
    provides = [CcToolchainImportInfo],
)
