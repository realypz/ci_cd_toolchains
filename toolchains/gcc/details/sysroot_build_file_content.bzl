SYSROOT_BUILD_FILE_CONTENT = """\
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libstdcxx",
    srcs = glob(
        include = ["**/libstdc++.so*"],
        exclude = ["**/*.py"],
    ),
    visibility = ["//visibility:public"],
)

sanitizers = ["asan", "lsan", "tsan", "ubsan"]

exports_files(glob([
    "**/lib{}.so*".format(san)
    for san in sanitizers
]))

[filegroup(
    name = "lib{}_files".format(san),
    srcs = glob(["**/lib{}.so*".format(san)]),
    visibility = ["//visibility:public"],
) for san in sanitizers]

[cc_library(
    name = "lib{}".format(san),
    srcs = glob(["**/lib{}.so*".format(san)]),
    visibility = ["//visibility:public"],
) for san in sanitizers]
"""
