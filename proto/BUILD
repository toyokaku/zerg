load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_go//proto:def.bzl", "go_proto_library")

proto_library(
    name = "proto_lib",
    srcs = glob(["*.proto"]),
    visibility = ["//visibility:public"],
)

go_proto_library(
    name = "proto_go",
    importpath = "github.com/zerg/proto",
    protos = [":proto_lib"],
    compilers = ["@rules_go//proto:go_grpc"],
    visibility = ["//visibility:public"],
)

# Export proto files for Flutter/Dart code generation
filegroup(
    name = "proto_files",
    srcs = glob(["*.proto"]),
    visibility = ["//visibility:public"],
) 