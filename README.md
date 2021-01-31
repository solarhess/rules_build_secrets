# rules_build_secrets Secrets in your Bazel Build

The rules_build_secrets will allow you to easily import secrets into your bazel build process.
In many existing build environments, the build process needs to access resources protected by
password credentials: private docker repos, private maven repos, cloud provider API keys, etc.
There should be a way to easily and securely load and use those values with Bazel.

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
    load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

    git_repository(
        name = "com_github_solarhess_rules_build_secrets",
        remote = "http://github.com/solarhess/rules_build_secrets",
        commit = "103b222eba64355b93649b06ecfe3844466b5a65",  # update as necessary
    )

    load("@com_github_solarhess_rules_build_secrets//lib:secrets.bzl", "environment_secrets")

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


## Planned Features

Send me your feedback on what would be useful to add.

* Import secrets from a local encrypted file (in progress see branch simplecrypt-vault)
* Import secrets from Hashicorp Vault APIs
* Render secrets into standard secret formats:
  * Docker config.json,
  * Maven settings.xml
  * NPM
  * And more (contact me with ideas)
