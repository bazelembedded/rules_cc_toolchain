def _no_op(ctx):
    pass

sysroot_package = rule(
    _no_op,
    doc = "Marks a package as a sysroot. This rule serves as a placeholder for\
other labels to point to.",
)
