{  
  fmx.tools.ai = {
    nixos = { inputs', ... }:
    {
      environment.systemPackages = with inputs'.llm-agents.packages; [
        rtk
        codegraph
      ];
    };
  };

  # flake-file.inputs.llm-agents = {
  #   # enable = !config.flake-file.inputs.fmway-inputs.enable or false;
  #   url = "github:numtide/llm-agents.nix";
  #   inputs = {
  #     nixpkgs.follows = "nixpkgs";
  #     systems.follows = "systems";
  #     flake-parts.follows = "flake-parts";
  #   };
  # };
}
