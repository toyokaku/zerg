filegroup(
    name = "core_infrastructure",
    srcs = [
        "//k3s/core:traefik",
        "//k3s/core:cert-manager",
        "//k3s/core:nats",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ingress_config",
    srcs = [
        "//k3s/ingress:routes",
        "//k3s/ingress:tls",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "service_deployments",
    srcs = [
        "//badger:badger_deployment",
        "//overmind:overmind_deployment",
        "//frontend:frontend_deployment",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "secrets",
    srcs = [
        "//k3s/core:secrets",
    ],
    visibility = ["//visibility:public"],
) 