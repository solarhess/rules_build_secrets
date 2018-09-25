load("//lib:secrets.bzl","environment_secrets")

####
# Declare secret variables from the environment
# In a remote project called "env"
environment_secrets(
    name="env", 
    entries = {
        "MAVEN_USER": "<REQUIRED>",
        "MAVEN_PASS": "<REQUIRED>",
    },
)