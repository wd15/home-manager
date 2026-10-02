{ pkgs, hostName, ... }:
let
  isLily = hostName == "lily";
  emacsFontSize = if isLily then 140 else 110;
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;

    extraPackages = epkgs: with epkgs; [
      better-defaults
      material-theme
      afternoon-theme
      yaml
      yaml-mode
      markdown-mode
      ox-pandoc
      use-package
      solarized-theme
      nix-mode
      nixos-options
      python-mode
      elpy
      rainbow-identifiers
      haskell-mode
      git-commit
      gptel

      # ---- Quarto mode ----
      quarto-mode
      polymode
      poly-markdown
      julia-mode
      poly-R
      request

      # ---- DOOM look/feel ----
      doom-themes
      doom-modeline
      all-the-icons
      nerd-icons

      # ---- Minibuffer & Completion ----
      vertico
      marginalia
      orderless

      # ---- Minimap + File Tree ----
      minimap
      treemacs
      treemacs-all-the-icons

      # ---- Org & Research ----
      org-roam
      org-roam-ui
      pdf-tools
      org-noter
    ];

    extraConfig = ''
      ${builtins.readFile ./core.el}
      ${builtins.readFile ./org-mode.el}

      ;; ---- Dynamic Nix Configuration ----
      ;; This stays in Nix so it can evaluate the emacsFontSize variable
      (set-face-attribute 'default nil
        :font "FiraCode Nerd Font"
        :height ${toString emacsFontSize})
    '';
  };
}
