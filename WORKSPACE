http_archive(
    name = "io_bazel_rules_go",
    urls = ["https://github.com/scele/rules_go/archive/c6590d6723b66a5087d451105403bae3d6bb8ac3.tar.gz"],
    strip_prefix = "rules_go-c6590d6723b66a5087d451105403bae3d6bb8ac3",
    sha256 = "1b076469a93196162f39aac88a8d5c3cf03b7a8479aa5e3e85536bc3d2129494",
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_register_toolchains(go_version = "1.9")

go_rules_dependencies()

load("//lib:secrets.bzl","environment_secrets")

####
# Declare secret variables from the environment
# In a remote project called "env"
environment_secrets(
    name="env",
    keys=[
        "MAVEN_USER",
        "MAVEN_PASS"
        ],
)
