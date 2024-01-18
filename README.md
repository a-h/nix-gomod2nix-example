# gomod2nix example

## Tasks

### develop

`nix develop` creates a shell containing the `gomod2nix` tool.

```
nix develop
```

### create-toml

Running `gomod2nix` creates the `gomod2nix.toml` file required by the build process.

```
gomod2nix
```

### build

Execute the build with `nix build`.

```
nix build
```

### sbom

Since we have each dependency as a distinct Nix store path, the SBOM output includes all of the Go modules, unlike `buildGoModule` where it's just a blob of dependencies.

```
sbomnix . --buildtime
```
