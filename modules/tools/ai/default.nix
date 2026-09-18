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
}
