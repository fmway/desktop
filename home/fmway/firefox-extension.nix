pkgs: (with pkgs.nur.repos.rycee.firefox-addons; [
  metamask
  # multi-account-containers
  violentmonkey
  # greasemonkey
  # gesturefy
  # tree-style-tab
  # react-devtools
  # search-by-image
  # firefox-color
  # vue-js-devtools
]) ++ pkgs.lib.optionals (pkgs ? fmway) (with pkgs.fmway.firefox-addons; [
  xdm_v8
  what-font
  # wakatime
  # stayfree
  firefox-relay
  # preact-devtools
])
