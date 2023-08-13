TOOLCHAIN_BUILD_FILE_CONTENT = """\
load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@{main_workspace_name}//toolchains/gcc:cc_toolchain_config.bzl", "cc_toolchain_config")
load("//:tool_paths.bzl", "tool_paths")

package(default_visibility = ["//visibility:public"])

sysroot = "{sysroot}"

##### C++ toolchain #####
cc_toolchain(
    name = "_cc_toolchain",
    all_files = ":all_files",
    ar_files = ":ar_files",
    as_files = ":as_files",
    compiler_files = ":compiler_files",
    dwp_files = ":dwp_files",
    linker_files = ":linker_files",
    objcopy_files = ":objcopy_files",
    strip_files = ":strip_files",
    supports_param_files = 0,
    toolchain_config = ":cc_toolchain_config",
    toolchain_identifier = "gcc-toolchain",
)

toolchain(
    name = "gcc_toolchain",
    exec_compatible_with = {target_compatible_with}, # TODO: Add Linux flag as a constraint.
    target_compatible_with = ["@ypz_ci_cd_toolchains//toolchains/gcc/platforms:compiler_name_gcc"] + {target_compatible_with},
    toolchain = ":_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

##### C++ toolchain (end) #####

##### Details below #####
cc_toolchain_config(
    name = "cc_toolchain_config",
    builtin_sysroot = sysroot,
    cxx_builtin_include_directories = {cxx_builtin_include_directories},
    extra_cflags = {extra_cflags},
    extra_cxxflags = {extra_cxxflags},
    extra_fflags = {extra_fflags},
    extra_ldflags ={extra_ldflags},
    includes = {includes},
    tool_paths = tool_paths,
)

filegroup(
    name = "all_files",
    srcs = [
        ":ar_files",
        ":as_files",
        ":compiler_files",
        ":dwp_files",
        ":linker_files",
        ":objcopy_files",
        ":strip_files",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        "@{toolchain_files_repository_name}//:compiler_files",
        ":as",
        ":gcc",
        ":gfortran",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        "@{toolchain_files_repository_name}//:linker_files",
        ":ar",
        ":gcc",
        ":ld",
    ],
)

filegroup(
    name = "ar_files",
    srcs = [
        "@{toolchain_files_repository_name}//:ar_files",
        ":ar",
    ],
)

filegroup(
    name = "as_files",
    srcs = [
        "@{toolchain_files_repository_name}//:as_files",
        ":as",
    ],
)

filegroup(
    name = "dwp_files",
    srcs = ["@{toolchain_files_repository_name}//:dwp_files"],
)

filegroup(
    name = "objcopy_files",
    srcs = [
        "@{toolchain_files_repository_name}//:objcopy_files",
        ":objcopy",
    ],
)

filegroup(
    name = "strip_files",
    srcs = [
        "@{toolchain_files_repository_name}//:strip_files",
        ":strip",
    ],
)

filegroup(
    name = "gcc",
    srcs = [
        "bin/cpp",
        "bin/g++",
        "bin/gcc",
    ],
)

filegroup(
    name = "gfortran",
    srcs = ["bin/gfortran"],
)

filegroup(
    name = "ld",
    srcs = ["bin/ld"],
)

filegroup(
    name = "ar",
    srcs = ["bin/ar"],
)

filegroup(
    name = "as",
    srcs = ["bin/as"],
)

filegroup(
    name = "nm",
    srcs = ["bin/nm"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/objcopy"],
)

filegroup(
    name = "objdump",
    srcs = ["bin/objdump"],
)

filegroup(
    name = "strip",
    srcs = ["bin/strip"],
)
"""
