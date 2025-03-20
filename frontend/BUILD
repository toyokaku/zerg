load("@bazel_skylib//rules:write_file.bzl", "write_file")

# Flutter script to run the app
write_file(
    name = "flutter_run_script",
    out = "run_flutter.sh",
    content = [
        "#!/bin/bash",
        "cd $(dirname $0)",
        "flutter run -d web-server --web-port=8080 \"$@\"",
    ],
    is_executable = True,
)

# Runner for the Flutter app
sh_binary(
    name = "frontend",
    srcs = ["run_flutter.sh"],
    data = glob([
        "lib/**/*",
        "assets/**/*",
        "pubspec.yaml",
        "web/**/*",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

# For compatibility with existing references
filegroup(
    name = "frontend_files",
    srcs = glob(["web/**/*"]),
    visibility = ["//visibility:public"],
)

# Kubernetes deployment
filegroup(
    name = "frontend_deployment",
    srcs = ["k8s/frontend/deployment.yaml"],
    visibility = ["//visibility:public"],
) 