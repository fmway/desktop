{  
  fmx.tools.ai = {
    includes = [ <fmx/tools/ai/_> ];
    nixos = { inputs', ... }:
    {
      environment.systemPackages = with inputs'.llm-agents.packages; [
        rtk
        codegraph
        gitnexus
        ai-memory
      ];
    };

    inputs = { inputs, ... }:
    {
      llm-agents = {
        enable = !inputs.fmway-inputs.enable or true;
        url = "github:numtide/llm-agents.nix";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          systems.follows = "systems";
          flake-parts.follows = "flake-parts";
        };
      };
    };
  };
}
