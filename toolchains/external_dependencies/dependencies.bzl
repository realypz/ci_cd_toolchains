load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def fetch_external_dependencies():
    ##### MISC external bazel workspaces #####
    http_archive(
        name = "bazel_skylib",
        sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        ],
    )
    ##### MISC external bazel workspaces (end) #####

    ##### Bazel buildifier #####
    # TODO: Right now this buildifier is only supported to run on linux amd64 platform.
    http_file(
        name = "buildifier-linux-amd64",
        executable = True,
        sha256 = "51bc947dabb7b14ec6fb1224464fbcf7a7cb138f1a10a3b328f00835f72852ce",
        urls = ["https://github.com/bazelbuild/buildtools/releases/download/v6.1.2/buildifier-linux-amd64"],
    )
    ##### Bazel buildifier (end) #####
