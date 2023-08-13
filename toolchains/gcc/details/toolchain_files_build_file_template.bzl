TOOLCHAIN_FILES_BUILD_FILE_CONTENT = """\
# Export all binary files:
exports_files(
    glob(["bin/**"]),
    visibility = ["//visibility:public"],
)

# GCC

sysroot_label = "{sysroot_label}"

filegroup(
    name = "compiler_files",
    srcs = [
        ":as",
        ":gcc",
        ":gfortran",
        ":include",
    ] + ([sysroot_label] if sysroot_label else []),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":gcc",
        ":ld",
        ":ld.bfd",
        ":lib",
    ] + ([sysroot_label] if sysroot_label else []),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "include",
    srcs = glob([
        "lib/gcc/{platform_directory_glob_pattern}/*/include/**",
        "lib/gcc/{platform_directory_glob_pattern}/*/include-fixed/**",
        "{platform_directory_glob_pattern}/include/**",
        "{platform_directory_glob_pattern}/sysroot/usr/include/**",
        "{platform_directory_glob_pattern}/include/c++/*/**",
        "{platform_directory_glob_pattern}/include/c++/*/{platform_directory_glob_pattern}/**",
        "{platform_directory_glob_pattern}/include/c++/*/backward/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(
        include = [
            "lib*/**",
            "{platform_directory_glob_pattern}/lib*/**",
            "**/*.so",
        ],
        exclude = ["lib*/**/*python*/**"],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gcc",
    srcs = [
        "bin/{binary_prefix}-linux-cpp.br_real",
        "bin/{binary_prefix}-linux-cpp",
        "bin/{binary_prefix}-linux-g++.br_real",
        "bin/{binary_prefix}-linux-g++",
        "bin/{binary_prefix}-linux-gcc.br_real",
        "bin/{binary_prefix}-linux-gcc",
    ] + glob([
        "**/cc1plus",
        "**/cc1",
        # These shared objects are needed at runtime by GCC when linked dynamically to them.
        "lib/libgmp.so*",
        "lib/libmpc.so*",
        "lib/libmpfr.so*",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gfortran",
    srcs = [
        "bin/{binary_prefix}-linux-gfortran",
        "bin/{binary_prefix}-linux-gfortran.br_real",
    ],
    visibility = ["//visibility:public"],
)

# Binutils

filegroup(
    name = "ar_files",
    srcs = [":ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "as_files",
    srcs = [":as"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "dwp_files",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy_files",
    srcs = [":objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip_files",
    srcs = [":strip"],
    visibility = ["//visibility:public"],
)

[
    filegroup(
        name = bin,
        srcs = [
            "bin/{binary_prefix}-linux-" + bin,
        ] + glob([
            "bin/{binary_prefix}-buildroot-*-" + bin,
        ]),
        visibility = ["//visibility:public"],
    )
    for bin in [
        "ar",
        "as",
        "ld",
        "ld.bfd",
        "nm",
        "objcopy",
        "objdump",
        "ranlib",
        "readelf",
        "strip",
    ]
]
"""
