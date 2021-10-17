# Helpers

## Building

This project uses Nix (you will need to enable flakes) and you can accelerate builds by using the binary cache `programmerino` with the command:
```
cachix use programmerino
```

and ultimately build with `nix build` which will place a binary in `result` or `nix build .#nuget` which will place a binary in `result-nuget`