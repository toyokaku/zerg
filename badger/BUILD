load("@rules_go//go:def.bzl", "go_library", "go_test")

# Go library
go_library(
    name = "badger_lib",
    srcs = [],
    importpath = "github.com/zerg/badger",
    visibility = ["//visibility:public"],
    deps = ["//badger/cmd:badger_lib"],
)

# Kubernetes deployment
filegroup(
    name = "badger_deployment",
    srcs = ["k8s/badger/deployment.yaml"],
    visibility = ["//visibility:public"],
)

# Tests
go_test(
    name = "badger_test",
    srcs = glob(["internal/**/*_test.go"], allow_empty = True),
    embed = ["//badger/cmd:badger_lib"],
    visibility = ["//visibility:public"],
) 