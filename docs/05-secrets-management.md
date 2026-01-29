# Secrets Management

## Why Secrets Need Special Handling

The Nix store is world-readable. Anything in your flake ends up in `/nix/store` with permissions `444`, visible to all users. This means:

```nix
# NEVER do this - password visible in /nix/store
environment.etc."myapp/config".text = ''
  password = "supersecret123"
'';
```

Even if you delete it from your config, it remains in the store until garbage collected—and in your Git history forever.

## Solutions Overview

| Tool | Encryption | Key Management | Best For |
|------|-----------|----------------|----------|
| sops-nix | age, GPG, cloud KMS | SSH keys, age keys | Most users |
| agenix | age only | SSH keys | Simple setups |

Both decrypt secrets at system activation time, placing them in `/run/secrets/` (a tmpfs).

## sops-nix

### Setup

```nix
# flake.nix
{
  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, sops-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        sops-nix.nixosModules.sops
        ./configuration.nix
      ];
    };
  };
}
```

### Configuration

```nix
# configuration.nix
{ config, ... }:
{
  # Use host SSH key for decryption
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Or use a dedicated age key
  # sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Default secrets file
  sops.defaultSopsFile = ./secrets/secrets.yaml;

  # Define secrets
  sops.secrets.my-password = {
    # Optional: owner/group/mode
    owner = "myapp";
    group = "myapp";
    mode = "0400";
  };

  sops.secrets."database/password" = {
    # Nested keys use / separator
  };
}
```

### Creating Secrets

1. Create `.sops.yaml` in your repo root:

```yaml
# .sops.yaml
keys:
  - &admin_alice age1...
  - &server_myhost age1...  # From ssh-to-age

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *admin_alice
          - *server_myhost
```

2. Get your host's age public key:

```bash
# Convert SSH host key to age
nix-shell -p ssh-to-age --run \
  'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

3. Create/edit secrets:

```bash
# Create new secrets file
nix-shell -p sops --run 'sops secrets/secrets.yaml'
```

```yaml
# secrets/secrets.yaml (plaintext while editing)
my-password: supersecret123
database:
  password: dbpass456
  connection-string: postgres://user:dbpass456@localhost/db
```

### Using Secrets

```nix
{ config, ... }:
{
  sops.secrets.api-key = {};

  services.myapp = {
    enable = true;
    # Reference the decrypted secret path
    environmentFile = config.sops.secrets.api-key.path;
  };

  # Or for config files that need secrets
  systemd.services.myservice = {
    serviceConfig = {
      LoadCredential = "api-key:${config.sops.secrets.api-key.path}";
    };
    script = ''
      API_KEY=$(cat $CREDENTIALS_DIRECTORY/api-key)
      exec myservice --api-key "$API_KEY"
    '';
  };
}
```

## agenix

### Setup

```nix
# flake.nix
{
  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, agenix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

### Configuration

Create `secrets/secrets.nix`:

```nix
# secrets/secrets.nix
let
  # User keys (from ~/.ssh/id_ed25519.pub)
  alice = "ssh-ed25519 AAAA...";

  # Host keys (from /etc/ssh/ssh_host_ed25519_key.pub)
  myhost = "ssh-ed25519 AAAA...";

  allKeys = [ alice myhost ];
in
{
  "my-secret.age".publicKeys = allKeys;
  "database-password.age".publicKeys = allKeys;
}
```

### Creating Secrets

```bash
# Enter the secrets directory
cd secrets

# Edit/create a secret (opens $EDITOR)
agenix -e my-secret.age

# Re-key all secrets after adding new keys
agenix -r
```

### Using Secrets

```nix
# configuration.nix
{ config, ... }:
{
  age.secrets.my-secret = {
    file = ./secrets/my-secret.age;
    owner = "myapp";
    group = "myapp";
    mode = "0400";
  };

  services.myapp = {
    passwordFile = config.age.secrets.my-secret.path;
  };
}
```

## Comparison

### sops-nix Advantages
- Multiple encryption backends (age, GPG, AWS KMS, GCP KMS, Azure Key Vault)
- Structured secrets (YAML/JSON with nested keys)
- Can encrypt only specific values in a file
- Better tooling for teams

### agenix Advantages
- Simpler—age only, fewer concepts
- Lightweight
- Each secret is a separate file
- Easier to audit

### When to Use Each

**Choose sops-nix if:**
- You need cloud KMS integration
- You have many related secrets (nested YAML)
- You're working in a team with complex key management

**Choose agenix if:**
- You want simplicity
- You have few secrets
- You prefer one file per secret

## Best Practices

### 1. Never Commit Unencrypted Secrets

```bash
# .gitignore
*.age.plain
*.decrypted
secrets/*.yaml.plain
```

### 2. Use Host Keys for Servers

```nix
# Host SSH keys exist on fresh installs
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

### 3. Separate Secrets by Environment

```
secrets/
├── common.yaml       # Shared secrets
├── desktop.yaml      # Desktop-specific
└── server.yaml       # Server-specific
```

### 4. Minimal Secret Exposure

```nix
# Good: only the service can read it
sops.secrets.api-key = {
  owner = "myservice";
  mode = "0400";
};

# Bad: world-readable
sops.secrets.api-key = {
  mode = "0444";  # Don't do this
};
```

### 5. Rotate Keys Regularly

```bash
# After revoking old keys, re-encrypt all secrets
sops updatekeys secrets/secrets.yaml
# or for agenix
agenix -r
```

## Further Reading

- [sops-nix](https://github.com/Mic92/sops-nix)
- [agenix](https://github.com/ryantm/agenix)
- [NixOS Wiki - Secret Comparison](https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes)
- [SOPS](https://github.com/getsops/sops)
