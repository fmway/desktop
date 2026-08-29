{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };
  # flake-file.nixConfig = {
  #   extra-substituters = [ "https://cache.numtide.com" ];
  #   extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  # };
  # den.default.includes = [
  #   (lib.mkCross {
  #     nix.settings = {
  #       extra-substituters = [ "https://cache.numtide.com" ];
  #       extra-trusted-public-keys = [
  #         "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  #       ];
  #     };
  #   })
  # ];
}
