load("@rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "cmd_lib",
    srcs = ["main.go"],
    importpath = "github.com/zerg/badger/cmd",
    visibility = ["//visibility:public"],
    deps = [
        "//proto:proto_go",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_google_grpc//reflection:go_default_library",
    ],
)

go_binary(
    name = "badger",
    embed = [":cmd_lib"],
    visibility = ["//visibility:public"],
) 