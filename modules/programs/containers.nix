{ config, lib, pkgs, ... }:

{
  # Podman for rootless containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Docker CLI compatibility
    defaultNetwork.settings.dns_enabled = true;
  };

  # Container tools
  environment.systemPackages = with pkgs; [
    podman-compose    # docker-compose compatible
    podman-tui        # Terminal UI for podman
    dive              # Explore docker images
    skopeo            # Container image operations

    # Kubernetes tools
    kubectl
    kind              # Kubernetes in Docker
    kubernetes-helm   # Helm charts
    k9s               # Kubernetes TUI
  ];

  # Enable container registries
  virtualisation.containers = {
    enable = true;
    registries.search = [
      "docker.io"
      "ghcr.io"
      "quay.io"
    ];
  };
}
