load(
    "@rules_cc_toolchain//cc_toolchain:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

LIB_INFO = {
    "armv6_m_nofp": {
        "constraint_values": [
            "@platforms//cpu:armv6-m",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v6-m/nofp",
    },
    "armv8_m_fpv5_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv8-m",
            "@embedded_platforms//fpu:fpv5_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v8-m.main+dp/hard",
    },
    "armv8_m_fpv5_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv8-m",
            "@embedded_platforms//fpu:fpv5_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v8-m.main+dp/softfp",
    },
    "armv8_m_fpv5_sp_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv8-m",
            "@embedded_platforms//fpu:fpv5_sp_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v8-m.main+fp/hard",
    },
    "armv8_m_fpv5_sp_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv8-m",
            "@embedded_platforms//fpu:fpv5_sp_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v8-m.main+fp/softfp",
    },
    "armv7_vfpv4_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv7",
            "@embedded_platforms//fpu:vfpv4_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v7+fp/hard",
    },
    "armv7_vfpv4_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv7",
            "@embedded_platforms//fpu:vfpv4_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v7+fp/softfp",
    },
    "armv7e_m_vfpv4_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:vfpv4_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v7e-m+fp/hard",
    },
    "armv7e_m_vfpv4_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:vfpv4_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v7e-m+fp/softfp",
    },
    "armv7e_m_fpv5_sp_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:fpv5_sp_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v7e-m+fp/hard",
    },
    "armv7e_m_fpv5_sp_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:fpv5_sp_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v7e-m+fp/softfp",
    },
    "armv7e_m_nofp": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v7e-m/nofp",
    },
    "armv8_a_nofp": {
        "constraint_values": [
            "@platforms//cpu:arm64",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v8-a/nofp",
    },
    "armv7e_m_fpv5_d16_hard": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:fpv5_d16",
            "@embedded_platforms//fpu:hard",
        ],
        "lib_path": "v7e-m+dp/hard",
    },
    "armv7e_m_fpv5_d16_softfp": {
        "constraint_values": [
            "@platforms//cpu:armv7e-m",
            "@embedded_platforms//fpu:fpv5_d16",
            "@embedded_platforms//fpu:soft",
        ],
        "lib_path": "v7e-m+dp/softfp",
    },
    "armv7_nofp": {
        "constraint_values": [
            "@platforms//cpu:armv7",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v7/nofp",
    },
    "armv8_m_nofp": {
        "constraint_values": [
            "@platforms//cpu:armv8-m",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v8-m.main/nofp",
    },
    "armv7_m_nofp": {
        "constraint_values": [
            "@platforms//cpu:armv7-m",
            "@embedded_platforms//fpu:none",
        ],
        "lib_path": "v7-m/nofp",
    },
}

def gcc_arm_none_cc_toolchain_import(name, libname, libprefix = "arm-none-eabi/lib/thumb", **kwargs):
    """ Imports a newlib lib from the gcc arm none toolchain """
    cc_toolchain_import(
        name = name,
        static_library = select({
            condition: lib_path
            for condition, lib_path in [
                (
                    "@rules_cc_toolchain//config:" + config_setting,
                    libprefix + "/" + config_info["lib_path"] + "/" + libname,
                )
                for config_setting, config_info in LIB_INFO.items()
            ] + [
                ("//conditions:default", None),
            ]
        }),
        target_compatible_with = select({
            condition: compatible_with
            for condition, compatible_with in [(
                "@rules_cc_toolchain//config:" + config_setting,
                [],
            ) for config_setting in LIB_INFO.keys()] + [(
                "//conditions:default",
                ["@platforms//:incompatible"],
            )]
        }),
        **kwargs
    )
