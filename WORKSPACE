workspace(name = "ci_cd_toolchains")

load("//toolchains/external_dependencies:dependencies.bzl", "fetch_external_dependencies")
fetch_external_dependencies()

load("//toolchains/cpp:register_toolchains.bzl", "register_example_toolchains")
register_example_toolchains()

# Might be unnecessary
# register_execution_platforms("//toolchains/cpp/platforms:linux_x86")
# register_execution_platforms("//toolchains/cpp/platforms:linux_arm64")
