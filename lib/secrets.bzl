BUILD_BZL_CONTENTS='''
filegroup(
    name="secrets",
    srcs=["secrets.bzl"],
    visibility=["//visibility:public"]
)
'''

UNSET_VALUE = "______UNSET______"
REQUIRED_VALUE = "<REQUIRED>"

def _environment_secrets_impl(repository_ctx):
    env = repository_ctx.os.environ
    entries = repository_ctx.attr.entries

    lines = ["# Generated - do not modify"]
    missing = []

    for key, defaultValue in entries.items():
        value = env.get(key, UNSET_VALUE)
        if value == UNSET_VALUE and defaultValue == REQUIRED_VALUE:
            missing.append(key)
        elif value == UNSET_VALUE and defaultValue:
            value = defaultValue

        # Escape quotes and backslashes
        value = value.replace("\\","\\\\")
        value = value.replace("\"","\\\"")

        line = "{0}=\"{1}\"".format(key, value)
        lines.append(line)

    if len(missing) > 0 : 
        fail("Required Secret environment variables were empty: "+ (",".join(missing)) ) 

    secrets_file = "\n".join(lines)

    repository_ctx.file("secrets.bzl", secrets_file)
    repository_ctx.file("BUILD.bazel", BUILD_BZL_CONTENTS)

the_new_rule = repository_rule(
    implementation = _environment_secrets_impl,
    attrs = {
        "entries": attr.string_dict(
            default = {},
        ),
    },
)
"""

Explicitly import secrets from the environment into the workspace. The 'entries'
is a string -> string key/value mapping such that the key is the name of the
environment variable to import.  If the value is the special token '<REQUIRED>'
the build will fail if the variable is unset or empty.  Otherwise the value will
be used as the default.

    environment_secrets(
        name="env", 
        entries = {
            "MAVEN_REPO_USER": "<REQUIRED>",
            "MAVEN_REPO_PASSWORD": "<REQUIRED>",
            "DOCKER_PASSWORD": "<REQUIRED>",
            "DOCKER_URL": "index.docker.io",
        },
    )

In the example above, DOCKER_URL will use the value 'index.docker.io' if the
"DOCKER_URL" environment variable is not set.

Then in build scripts you can reference these by importing a custom bzl file.

    # Import a secret into the local BUILD.bazel environment
    load("@env//:secrets.bzl","MAVEN_REPO_USER")

    # Use the value
    sample_rule(arg=MAVEN_REPO_USER)

"""
def environment_secrets(name, entries):

    the_new_rule(name = name, entries = entries)