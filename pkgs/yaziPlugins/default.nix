{ internal, self, lib, ... }: let
  version = "unstable-2025-08-11";

  src = self.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "e95c7b384e7b0a9793fe1471f0f8f7810ef2a7ed";
    hash = "sha256-TUS+yXxBOt6tL/zz10k4ezot8IgVg0/2BbS8wPs9KcE=";
  };
  officials = a: builtins.foldl' (acc: curr: acc // {
    "${curr}".__output = {
      src.__assign = src;
      version.__assign = version;
    };
  }) a [ "chmod" "diff" "full-border" "git" "jump-to-char" "lsar" "mactag" "mime-ext" "mount" "no-status" "piper" "smart-enter" "smart-filter" "smart-paste" "vcs-files" "toggle-pane" ];
in {
  __infuse = officials {
    zoom.__add = {
      inherit version src;
      pname = "zoom.yazi";

      meta = {
        description = "Place code snippets from docs into this monorepo, so that users can update more easily via package manager";
        homepage = "https://github.com/yazi-rs/plugins";
        license = lib.licenses.mit;
      };
    };
    bunny.__add = rec {
      pname = "bunny.yazi";
      version = "1.3.2";

      src = self.fetchFromGitHub {
        owner = "stelcodes";
        repo = "bunny.yazi";
        rev = "v${version}";
        hash = "sha256-HnzuR12c4wJaI7dzZrf/Zdc6yCjvsfhPEcnzNNgcLnA=";
      };

      patches = [
        ./bunny.patch
      ];

      meta = {
        description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
        homepage = "https://github.com/stelcodes/bunny.yazi";
        changelog = "https://github.com/stelcodes/bunny.yazi/blob/${src.rev}/CHANGELOG.md";
        license = lib.licenses.mit;
      };
    };
  };
}
