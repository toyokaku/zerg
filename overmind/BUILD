load("@rules_go//go:def.bzl", "go_library", "go_test")

# Go library
go_library(
    name = "overmind_lib",
    srcs = [],
    importpath = "github.com/kooli/zerg/overmind",
    visibility = ["//visibility:public"],
    deps = ["//overmind/cmd/overmind:overmind"],
)

# Kubernetes deployment (bare metal)
filegroup(
    name = "overmind_deployment",
    srcs = ["k8s/overmind/deployment.yaml"],
    visibility = ["//visibility:public"],
)

# Tests
go_test(
    name = "overmind_test",
    srcs = glob(["internal/**/*_test.go"], allow_empty = True),
    embed = [":overmind_lib"],
    visibility = ["//visibility:public"],
) 