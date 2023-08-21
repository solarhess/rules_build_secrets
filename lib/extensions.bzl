load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_build_secret//lib:secrets.bzl","environment_secrets")

def _impl(ctx):
    module = ctx.modules[0]
    options = module.tags.options
    print(options[0].entries)
    maybe(
        environment_secrets,
        name = options[0].name,
        entries = options[0].entries
    )


options = tag_class(attrs={
    "name": attr.string(default = "env"),
    "entries": attr.string_dict(default = {
        "MAVEN_USER": "REQUIRED",
        "MAVEN_PASS": "REQUIRED",
    }),
})

rules_build_secret = module_extension(
    implementation = _impl,
    tag_classes = {"options": options},
)