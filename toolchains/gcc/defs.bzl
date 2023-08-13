# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This module provides the definitions for registering a GCC toolchain for C and C++.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//toolchains/gcc/sysroot:flags.bzl", "cflags", "cxxflags", "fflags", "includes", "ldflags")
load("//toolchains/gcc/details:toolchain_build_file_template.bzl", _TOOLCHAIN_BUILD_FILE_CONTENT = "TOOLCHAIN_BUILD_FILE_CONTENT")

# load("//toolchains/gcc/details:render_tool_paths.bzl", _render_tool_paths="render_tool_paths")
load("//toolchains/gcc/details:sysroot_build_file_content.bzl", _SYSROOT_BUILD_FILE_CONTENT = "SYSROOT_BUILD_FILE_CONTENT")
load("//toolchains/gcc/details:toolchain_files_build_file_template.bzl", _TOOLCHAIN_FILES_BUILD_FILE_CONTENT = "TOOLCHAIN_FILES_BUILD_FILE_CONTENT")

def _render_tool_paths(rctx, repository_name, toolchain_files_repository_name, binary_prefix):
    relative_tool_paths = {
        "ar": "external/{repository_name}/bin/{binary_prefix}-linux-ar".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "as": "external/{repository_name}/bin/{binary_prefix}-linux-as".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "cpp": "external/{repository_name}/bin/{binary_prefix}-linux-cpp".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "g++": "external/{repository_name}/bin/{binary_prefix}-linux-g++".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gcc": "external/{repository_name}/bin/{binary_prefix}-linux-gcc".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gcov": "external/{repository_name}/bin/{binary_prefix}-linux-gcov".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gfortran": "external/{repository_name}/bin/{binary_prefix}-linux-gfortran".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "ld": "external/{repository_name}/bin/{binary_prefix}-linux-ld".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "nm": "external/{repository_name}/bin/{binary_prefix}-linux-nm".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "objcopy": "external/{repository_name}/bin/{binary_prefix}-linux-objcopy".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "objdump": "external/{repository_name}/bin/{binary_prefix}-linux-objdump".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "strip": "external/{repository_name}/bin/{binary_prefix}-linux-strip".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
    }

    path_env = ":".join([
        "${{EXECROOT}}/external/{}/bin".format(repository)
        for repository in [repository_name, toolchain_files_repository_name]
    ])

    tool_paths = {}
    for name, tool_path in relative_tool_paths.items():
        wrapped_tool_path = paths.join("bin", name)
        rctx.template(
            wrapped_tool_path,
            rctx.attr._wrapper_sh_template,
            substitutions = {
                "__PATH__": path_env,
                "__binary__": tool_path,
            },
            executable = True,
        )
        tool_paths[name] = wrapped_tool_path
    return tool_paths

def _gcc_toolchain_impl(rctx):
    absolute_toolchain_root = str(rctx.path("."))
    execroot = paths.normalize(paths.join(absolute_toolchain_root, "..", ".."))
    toolchain_root = paths.relativize(absolute_toolchain_root, execroot)

    target_arch = rctx.attr.target_arch

    sysroot = ""
    if rctx.attr.sysroot:
        sysroot_label = Label(rctx.attr.sysroot)
        sysroot = "external/{workspace}/{package}".format(
            workspace = sysroot_label.workspace_name,
            package = sysroot_label.package,
        )

    cxx_builtin_include_directories = rctx.attr.includes
    for include in cxx_builtin_include_directories:
        if paths.is_absolute(include):
            fail("include ({}) must not be absolute".format(include))
        if not include.startswith("%sysroot%") and not include.startswith("%workspace%"):
            fail("include ({}) must be prefixed with %sysroot% or %workspace%".format(include))

    includes = [
        include.replace("%sysroot%", sysroot).replace("%workspace%", toolchain_root)
        for include in cxx_builtin_include_directories
    ]

    target_compatible_with = [
        v.format(target_arch = target_arch)
        for v in rctx.attr.target_compatible_with
    ]

    print(target_compatible_with)

    rctx.file("BUILD.bazel", _TOOLCHAIN_BUILD_FILE_CONTENT.format(
        main_workspace_name = rctx.attr.main_workspace_name,
        target_compatible_with = str(target_compatible_with),
        toolchain_files_repository_name = rctx.attr.toolchain_files_repository_name,

        # Sysroot
        sysroot = sysroot,

        # Includes
        cxx_builtin_include_directories = str(cxx_builtin_include_directories),

        # Flags
        extra_cflags = _format_flags(sysroot, toolchain_root, rctx.attr.extra_cflags),
        extra_cxxflags = _format_flags(sysroot, toolchain_root, rctx.attr.extra_cxxflags),
        extra_fflags = _format_flags(sysroot, toolchain_root, rctx.attr.extra_fflags),
        extra_ldflags = _format_flags(sysroot, toolchain_root, rctx.attr.extra_ldflags),
        includes = str(includes),
    ))

    binary_prefix = rctx.attr.binary_prefix
    tool_paths = _render_tool_paths(rctx, rctx.name, rctx.attr.toolchain_files_repository_name, binary_prefix)
    rctx.file("tool_paths.bzl", "tool_paths = {}".format(str(tool_paths)))

def _format_flags(sysroot, toolchain_root, flags):
    return str([
        flag.replace("%sysroot%", sysroot).replace("%workspace%", toolchain_root)
        for flag in flags
    ])

_FEATURE_ATTRS = {
    "binary_prefix": attr.string(
        doc = "An explicit prefix used by each binary in bin/.",
        mandatory = True,
    ),
    "extra_cflags": attr.string_list(
        doc = "Extra flags for compiling C.",
        default = [],
    ),
    "extra_cxxflags": attr.string_list(
        doc = "Extra flags for compiling C++.",
        default = [],
    ),
    "extra_fflags": attr.string_list(
        doc = "Extra flags for compiling Fortran.",
        default = [],
    ),
    "extra_ldflags": attr.string_list(
        doc = "Extra flags for linking." +
              " %sysroot% is rendered to the sysroot path." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "main_workspace_name": attr.string(
        doc = "The name given to the gcc-toolchain repository, if the default was not used.",
        default = "ypz_ci_cd_toolchains",
    ),
    "includes": attr.string_list(
        doc = "Extra includes for compiling C and C++." +
              " %sysroot% is rendered to the sysroot path." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "sysroot": attr.string(
        doc = "A sysroot to be used as the logical build root.",
        mandatory = True,
    ),
    "target_arch": attr.string(
        doc = "The target architecture this toolchain produces. E.g. x86_64.",
        mandatory = True,
    ),
    "target_compatible_with": attr.string_list(
        default = [
            "@platforms//os:linux",
            "@platforms//cpu:{target_arch}",
        ],
        doc = "contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.",
        mandatory = False,
    ),
    "toolchain_files_repository_name": attr.string(
        doc = "The name of the repository containing the toolchain files.",
        mandatory = True,
    ),
}

_PRIVATE_ATTRS = {
    "_wrapper_sh_template": attr.label(
        default = Label("//toolchains/gcc:wrapper.sh.tpl"),
    ),
}

gcc_toolchain = repository_rule(
    _gcc_toolchain_impl,
    attrs = dicts.add(
        _FEATURE_ATTRS,
        _PRIVATE_ATTRS,
    ),
)

_DEFAULT_GCC_VERSION = "10.3.0"

def gcc_register_toolchain(
        name,
        target_arch,
        gcc_version = _DEFAULT_GCC_VERSION,
        **kwargs):
    """Declares a `gcc_toolchain` and calls `register_toolchain` for it.

    Args:
        name: The name passed to `gcc_toolchain`.
        target_arch: The target architecture of the toolchain.
        gcc_version: The version of GCC used by the toolchain.
        **kwargs: The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.
    """
    sysroot = kwargs.pop("sysroot", None)
    if not sysroot:
        sysroot_variant = kwargs.pop("sysroot_variant", target_arch)
        sysroot_repository_name = "sysroot_{sysroot_variant}".format(sysroot_variant = sysroot_variant)
        sysroot = Label("@{sysroot_repository_name}//:sysroot".format(
            sysroot_repository_name = sysroot_repository_name,
        ))
        http_archive(
            name = sysroot_repository_name,
            build_file_content = _SYSROOT_BUILD_FILE_CONTENT,
            sha256 = _SYSROOTS[sysroot_variant].sha256,
            url = _SYSROOTS[sysroot_variant].url,
        )

    binary_prefix = kwargs.pop("binary_prefix", "arm" if target_arch == ARCHS.armv7 else target_arch)

    # The following glob matches all the cases:
    #   - aarch64-buildroot-linux-gnu
    #   - arm-buildroot-linux-gnueabihf
    #   - x86_64-buildroot-linux-gnu
    platform_directory_glob_pattern = "*-buildroot-linux-gnu*"

    toolchain_files_repository_name = "{name}_files".format(name = name)
    print("toolchain_files_repository_name =", toolchain_files_repository_name)
    http_archive(
        name = toolchain_files_repository_name,
        build_file_content = _TOOLCHAIN_FILES_BUILD_FILE_CONTENT.format(
            binary_prefix = binary_prefix,
            platform_directory_glob_pattern = platform_directory_glob_pattern,
            sysroot_label = str(sysroot),
        ),
        patch_cmds = [
            # The sysroot shipped with the bootlin toolchain should never be used.
            "find . -type d -name 'sysroot' -exec rm -rf {} +",
            # We also remove the libgfortran and libstdc++ that are outside the sysroot. They are
            # provided by our custom-built sysroot.
            "find . -type f -name 'libgfortran*' -exec rm \"{}\" \\;",
            "find . -type f -name 'libstdc++*' -exec rm \"{}\" \\;",
        ],
        strip_prefix = kwargs.pop("strip_prefix", _TOOLCHAINS[gcc_version][target_arch].strip_prefix),
        sha256 = kwargs.pop("sha256", _TOOLCHAINS[gcc_version][target_arch].sha256),
        url = kwargs.pop("url", _TOOLCHAINS[gcc_version][target_arch].url),
    )

    # (yang.peizheng): gcc_toolchain is a repo rule.
    gcc_toolchain(
        name = name,
        binary_prefix = binary_prefix,
        extra_cflags = kwargs.pop("extra_cflags", cflags),
        extra_cxxflags = kwargs.pop("extra_cxxflags", cxxflags),
        extra_fflags = kwargs.pop("extra_fflags", fflags),
        extra_ldflags = kwargs.pop("extra_ldflags", ldflags(target_arch, gcc_version)),
        includes = kwargs.pop("includes", includes(target_arch, gcc_version)),
        sysroot = str(sysroot),
        target_arch = target_arch,
        toolchain_files_repository_name = toolchain_files_repository_name,
        **kwargs
    )

    native.register_toolchains("@{}//:gcc_toolchain".format(name))

ARCHS = struct(
    aarch64 = "aarch64",
    armv7 = "armv7",
    x86_64 = "x86_64",
)

_SYSROOTS = {
    "aarch64": struct(
        sha256 = "b23690426137bdbf23c9572d8d6b3db6de30dc80b7cac148fb98b6d50d9fb192",
        url = "https://github.com/aspect-build/gcc-toolchain/releases/download/0.3.0/sysroot-base-aarch64.tar.xz",
    ),
    "armv7": struct(
        sha256 = "049865707f6c4c62e244b28ff4c7fe597539b0cff3bc6d4ca80ab93f845240e7",
        url = "https://github.com/aspect-build/gcc-toolchain/releases/download/0.3.0/sysroot-base-armv7.tar.xz",
    ),
    "x86_64": struct(
        sha256 = "b9993ee16de8c2c8111c4baa9ea1c554ef74c2b32b5768dc93fcec013b549d68",
        url = "https://github.com/aspect-build/gcc-toolchain/releases/download/0.3.0/sysroot-base-x86_64.tar.xz",
    ),
    "x86_64-X11": struct(
        sha256 = "36caaa7b9445ffe46142becdbce5733843d99efa70ac027ba82c2909f0ae6dc4",
        url = "https://github.com/aspect-build/gcc-toolchain/releases/download/0.3.0/sysroot-X11-x86_64.tar.xz",
    ),
}

_TOOLCHAINS = {
    "10.3.0": {
        "aarch64": struct(
            sha256 = "dec070196608124fa14c3f192364c5b5b057d7f34651ad58ebb8fc87959c97f7",
            strip_prefix = "aarch64--glibc--stable-2021.11-1",
            url = "https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2021.11-1.tar.bz2",
        ),
        "armv7": struct(
            sha256 = "6d10f356811429f1bddc23a174932c35127ab6c6f3b738b768f0c29c3bf92f10",
            strip_prefix = "armv7-eabihf--glibc--stable-2021.11-1",
            url = "https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2021.11-1.tar.bz2",
        ),
        "x86_64": struct(
            sha256 = "6fe812add925493ea0841365f1fb7ca17fd9224bab61a731063f7f12f3a621b0",
            strip_prefix = "x86-64--glibc--stable-2021.11-5",
            url = "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64/tarballs/x86-64--glibc--stable-2021.11-5.tar.bz2",
        ),
    },
}
