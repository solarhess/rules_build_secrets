import json


def get_bzl_secrets():
    with open("../env/secrets.bzl") as file:
        return {
            # Remove the leading `"` and trailing `"\n`.
            key: value[1:-2]
            for (key, value) in (
                line.split("=", 1)
                for line in file
                if not line.startswith("#")
            )
        }


def get_json_secrets():
    with open("../env/secrets.json") as file:
        return json.load(file)


if __name__ == "__main__":
    bzl_secrets = get_bzl_secrets()
    json_secrets = get_json_secrets()

    assert set(bzl_secrets.keys()) == {"DEFAULT", "MAVEN_USER", "MAVEN_PASS"}
    assert json_secrets == bzl_secrets
