workspace(name = "ypz_ci_cd_toolchains")

load("//toolchains/external_dependencies:dependencies.bzl", "fetch_external_dependencies")
load("//toolchains/cpp:register_toolchains.bzl", "register_example_toolchains")

fetch_external_dependencies()

register_example_toolchains()

load("//toolchains/gcc:defs.bzl", "ARCHS", "gcc_register_toolchain")

gcc_register_toolchain(
    name = "gcc_toolchain_x86_64-ypz",
    sysroot_variant = "x86_64-X11",
    target_arch = ARCHS.x86_64,
)

# load()

# Might be unnecessary
# register_execution_platforms("//toolchains/cpp/platforms:linux_x86")
# register_execution_platforms("//toolchains/cpp/platforms:linux_arm64")
