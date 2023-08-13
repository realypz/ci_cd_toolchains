# ci_cd_toolchains
This repo some CI/CD toolchains that I've used for my personal projects.

# Bazel toolchain
Updated 2023-08-06, below is a most basic example picked from https://interrupt.memfault.com/blog/bazel-build-system-for-embedded-projects.

Some working building commands that correctly resolving the toolchian.
1. **Recommended**: Using `--platforms` to provide the constraints that will be matched with the toolchain.
    ```shell
    # Register the toolchain in `WORKSPACE`.
    register_toolchains(
        "//toolchains/cpp:clang_toolchain_a",
    )

    register_toolchains(
        "//toolchains/cpp:clang_toolchain_b",
    )

    # Command works with register_toolchain called above.
    bazelisk build --platforms=//toolchains/cpp/platforms:linux_x86 \
        --incompatible_enable_cc_toolchain_resolution \
        //example_code:main

    bazelisk build --platforms=//toolchains/cpp/platforms:linux_arm64 \
        --incompatible_enable_cc_toolchain_resolution \
        //example_code:main
    ```
    NOTE: `--host_platform` - defaults to `@bazel_tools//platforms:host_platform`, `--platforms` - defaults to `@bazel_tools//platforms:target_platform`.[https://bazel.build/extending/platforms#constraints-platforms]


2. **Less recommended**: Use toolchainsuite and `--cpu` and `--compiler` to resolve the toolchain.
The toolchains have be registered into a `cc_toolchain_suite` target.
    ```shell
    # Without register_toolchains() in workspace.
    bazelisk build --crosstool_top=//toolchains/cpp:cpp_toolchainsuite \
        --cpu=x86_64 --compiler=clang \
        //example_code:main

    bazelisk build --crosstool_top=//toolchains/cpp:cpp_toolchainsuite \
        --cpu=x64 --compiler=clang_x \
        //example_code:main
    ```

3. Format
    3.1 Format Bazel files.
    ```bash
    bazelisk run //toolchains/format:bazel_buildifier_fix
    ```
