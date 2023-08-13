def register_example_toolchains():
    """Register the example toolchains.
       (Will be replaced by a serious toolchain.)
    """
    native.register_toolchains(
        "//toolchains/cpp:clang_toolchain_a",
    )

    native.register_toolchains(
        "//toolchains/cpp:clang_toolchain_b",
    )
