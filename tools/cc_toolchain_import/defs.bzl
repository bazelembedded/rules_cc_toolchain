LinkingContextInfo = provider(
    fields = {
        "dynamic_libraries": "The shared library file.",
        "static_libraries": "The static library file.",
    },
    doc = "The linking context for a precompiled toolchain library.",
)

CompilationContextInfo = provider(
    fields = {
        "headers": "Depset of headers that make up this lib.",
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

def _linking_context(dynamic_library, static_library):
    return LinkingContextInfo(
        dynamic_libraries = dynamic_library,
        static_libraries = static_library,
    )

def _compilation_ctx(headers, includes):
    return CompilationContextInfo(
        headers = headers,
        includes = includes,
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
    return root_str + ctx.label.package + "/" + inc

def _cc_toolchain_import_impl(ctx):
    deps = ctx.attr.deps
    transitive_hdrs = []
    transitive_shared_libraries = []
    transitive_static_libraries = []
    if deps:
        transitive_hdrs = [
            dep[CcToolchainImportInfo].compilation_context.headers
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
    if not ctx.attr.includes:
        includes = []
    else:
        includes = ctx.attr.includes
    if not deps:
        transitive_includes = []
    else:
        transitive_includes = [
            dep[CcToolchainImportInfo].compilation_context.includes
            for dep in deps
        ]
    compilation_context = _compilation_ctx(
        depset(ctx.files.hdrs, transitive = transitive_hdrs),
        depset(
            [_normalise_include(ctx, inc) for inc in includes],
            transitive = transitive_includes,
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

    linking_context = _linking_context(
        depset(
            shared_library_list,
            transitive = transitive_shared_libraries,
        ),
        depset(
            static_library_list,
            transitive = transitive_static_libraries,
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
                            library_files,
                            transitive = transitive_static_libraries +
                                         transitive_shared_libraries +
                                         transitive_hdrs,
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
        "includes": attr.string_list(
            doc = "List of includes to apply to the headers",
            default = [],
        ),
        "static_library": attr.label(
            doc = "The precompiled static library.",
            allow_single_file = [".a", ".pic.a", ".lib"],
        ),
        "shared_library": attr.label(
            doc = "The precompiled shared library.",
            allow_single_file = [".so", ".dll", ".dylib"],
        ),
        "deps": attr.label_list(
            doc = "Toolchain libraries that this library depends on.",
            default = [],
        ),
    },
    provides = [CcToolchainImportInfo],
)
