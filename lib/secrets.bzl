BUILD_BZL_CONTENTS='''
filegroup(
    name="secrets",
    srcs=["secrets.bzl"],
    visibility=["//visibility:public"]
)
'''

UNSET_VALUE="______UNSET______"

def _environment_secrets_impl(repository_ctx):
    keys = repository_ctx.attr.keys
    failOnUnset = repository_ctx.attr.failOnUnset
    failOnEmpty = repository_ctx.attr.failOnEmpty

    env = repository_ctx.os.environ

    lines = []
    
    for key in keys :
        value = env.get(key,UNSET_VALUE)
        if value == UNSET_VALUE and failOnUnset :
                fail("Unset environment variable "+key)

        if value == "" and failOnEmpty:
            fail("Empty value for environment variable "+key)
        

        # Escape quotes and backslashes
        value = value.replace("\\","\\\\")
        value = value.replace("\"","\\\"")

        line = "{0}=\"{1}\"".format(key, value)
        print("Loading environment var secret "+line)
        lines.append(line)

    secrets_file = "\n".join(lines)

    # repository_ctx.file("settings.xml","<settings></settings>")
    repository_ctx.file("secrets.bzl", secrets_file)
    repository_ctx.file("BUILD.bazel", BUILD_BZL_CONTENTS)


"""
Explicitly import secrets from the environment into the workspace

    environment_secrets(
        name="env", 
        keys=[
            "MAVEN_REPO_USER",
            "MAVEN_REPO_PASSWORD",
            "DOCKER_PASSWORD",
            "DOCKER_URL"
            ],
    )

Then in build scripts you can reference these by importing a custom bzl file.

    # Import a secret into the local BUILD.bazel environment
    load("@env//:secrets.bzl","MAVEN_REPO_USER")

    #
    sample_rule(
        arg=MAVEN_REPO_USER)

"""
def environment_secrets( name, keys): 
    the_new_rule=repository_rule(
        implementation = _environment_secrets_impl,
        attrs = {
            "keys": attr.string_list(
                mandatory = False,
                default = keys
            ),
            "failOnEmpty": attr.bool(
                mandatory = False,
                default=True
            ),
            "failOnUnset": attr.bool(
                mandatory = False,
                default=True
            )
        },
        environ=keys
    )
    the_new_rule(name=name)