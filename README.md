# rules_build_secrets Secrets in your Bazel Build

The rules_build_secrets will allow you to easily import secrets into your bazel build process. 
In many existing build environments, the build process needs to access resources protected by
password credentials: private docker repos, private maven repos, cloud provider API keys, etc. 
There should be a way to easily and securely load and use those values with Bazel.

Current Features:
* Import the secrets from the build process's environment variables. 

Planned Features
* Import secrets from a local encrypted file
* Import secrets from Hashicorp Vault APIs
* Render secrets into template files
* Render secrets into standard secret formats: 
  * Docker config.json, 
  * Maven settings.xml
  * NPM 
  * And more (contact me with ideas)

## Usage
You can look at examples/BUILD.bazel for an example of how to use this. 
