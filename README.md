This rule helps you import secrets set in the build environment into your bazel
build script. This way you don't hard-code secrets into your codebase or import
them into the works. 

## Usage

Explicitly import secrets from the environment into the workspace. The 'entries'
is a string -> string key/value mapping such that the key is the name of the
environment variable to import.  If the value is the special token '<REQUIRED>'
the build will fail if the variable is unset or empty.  Otherwise the value will
be used as the default.

WORKSPACE:

```python 
    environment_secrets(
        name="env", 
        entries = {
            "MAVEN_REPO_USER": "<REQUIRED>",
            "MAVEN_REPO_PASSWORD": "<REQUIRED>",
            "DOCKER_PASSWORD": "<REQUIRED>",
            "DOCKER_URL": "index.docker.io",
        },
    )
```

In the example above, DOCKER_URL will use the value 'index.docker.io' if the
"DOCKER_URL" environment variable is not set.

Then in build scripts you can reference these by importing a custom bzl file.

BUILD.bazel

```python 
    # Import a secret into the local BUILD.bazel environment
    load("@env//:secrets.bzl","MAVEN_REPO_USER")

    # Use the value
    sample_rule(arg=MAVEN_REPO_USER)
```