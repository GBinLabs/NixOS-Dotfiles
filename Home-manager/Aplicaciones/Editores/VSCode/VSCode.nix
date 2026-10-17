{
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:
let
  flakePath = osConfig.programs.nh.flake or "/home/bin/.GitHub/NixOS-Dotfiles";

  hostName = osConfig.networking.hostName;

  ltexLs = pkgs.ltex-ls-plus;

  calepinCli = inputs.calepin.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = with pkgs; [
    # Nix
    nixd
    alejandra

    # Python
    ruff

    # Corrección gramatical
    ltex-ls-plus

    # Typst / Calepin
    typst
    calepinCli
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        # Nix
        jnoortheen.nix-ide

        # Corrección gramatical / prosa científica
        ltex-plus.vscode-ltex-plus

        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy
        charliermarsh.ruff

        # Typst
        myriad-dreamin.tinymist

        # Calepin
        vincentarel-bundock.calepin
      ];

      userSettings = {
        # ------------------------------------------------------------
        # Privacidad y reproducibilidad
        # ------------------------------------------------------------

        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";

        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;

        "github.gitAuthentication" = false;

        "security.promptForWorkspaceTrust" = false;

        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
        "sync.autoSync" = "disabled";

        "workbench.startupEditor" = "none";
        "workbench.startupEditorOverride" = "";

        "update.showReleaseNotes" = false;

        "workbench.editor.untitled.hint" = "hidden";
        "chat.commandCenter.enabled" = false;

        # ------------------------------------------------------------
        # Editor general
        # ------------------------------------------------------------

        "editor.fontFamily" = "'JetBrains Mono', monospace";
        "editor.fontSize" = 14;
        "editor.lineHeight" = 1.55;

        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = false;

        "editor.bracketPairColorization.enabled" = true;

        "editor.guides.bracketPairs" = true;
        "editor.guides.indentation" = true;

        "editor.minimap.enabled" = false;

        "editor.wordWrap" = "bounded";
        "editor.wordWrapColumn" = 100;

        "editor.rulers" = [
          80
          100
          120
        ];

        "editor.renderWhitespace" = "boundary";

        "editor.unicodeHighlight.ambiguousCharacters" = true;
        "editor.unicodeHighlight.invisibleCharacters" = true;

        # ------------------------------------------------------------
        # Archivos
        # ------------------------------------------------------------

        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;

        "files.autoSave" = "off";

        "files.exclude" = {
          "**/.git" = true;
          "**/.direnv" = true;

          "**/.calepin" = true;

          "**/result" = true;
          "**/result-*" = true;

          # Se muestra build en el explorador.
          "**/build" = false;
        };

        "search.exclude" = {
          "**/.git" = true;
          "**/.direnv" = true;

          "**/.calepin" = true;

          "**/result" = true;
          "**/result-*" = true;

          "**/build" = true;
        };

        # ------------------------------------------------------------
        # Nix
        # ------------------------------------------------------------

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";

        "nix.serverSettings" = {
          nixd = {
            formatting.command = [
              "${pkgs.alejandra}/bin/alejandra"
            ];

            options = {
              nixos.expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options";

              home-manager.expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
            };
          };
        };

        "[nix]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;

          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

        # ------------------------------------------------------------
        # LTeX+
        # ------------------------------------------------------------

        "ltex.ltex-ls.path" = "${ltexLs}";

        "ltex.enabled" = [
          "typst"
          "markdown"
          "bibtex"
        ];

        "ltex.language" = "es-AR";

        "ltex.additionalRules.enablePickyRules" = true;

        "ltex.checkFrequency" = "save";

        "ltex.java.initialHeapSize" = 128;
        "ltex.java.maximumHeapSize" = 1536;

        "ltex.completionEnabled" = false;

        "ltex.configurationTarget" = {
          dictionary = "workspaceFolderExternalFile";
          disabledRules = "workspaceFolderExternalFile";
          hiddenFalsePositives = "workspaceFolderExternalFile";
        };

        "ltex.dictionary" = {
          "es-AR" = [ ];
          "en-US" = [ ];
          "en-GB" = [ ];
        };

        "ltex.disabledRules" = {
          "es-AR" = [ ];
          "en-US" = [ ];
          "en-GB" = [ ];
        };

        "ltex.hiddenFalsePositives" = {
          "es-AR" = [ ];
          "en-US" = [ ];
          "en-GB" = [ ];
        };

        # ------------------------------------------------------------
        # Typst / Tinymist
        # ------------------------------------------------------------

        "tinymist.formatterMode" = "typstyle";
        "tinymist.formatterIndentSize" = 2;
        "tinymist.formatterPrintWidth" = 100;
        "tinymist.formatterProseWrap" = "none";

        # Dejamos a Calepin encargado del build final.
        "tinymist.exportPdf" = "never";

        "tinymist.showExportFileIn" = "editorTab";

        # Linting de Typst.
        "tinymist.lint.enabled" = true;
        "tinymist.lint.when" = "onSave";

        "[typst]" = {
          "editor.wordWrap" = "bounded";
          "editor.wordWrapColumn" = 100;

          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;

          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "myriad-dreamin.tinymist";
        };

        # ------------------------------------------------------------
        # Calepin
        # ------------------------------------------------------------

        "calepin.binaryPath" = "${calepinCli}/bin/calepin";

        # ------------------------------------------------------------
        # Python
        # ------------------------------------------------------------

        "python.languageServer" = "Pylance";
        "python.analysis.typeCheckingMode" = "basic";

        "ruff.lint.run" = "onSave";
        "ruff.fixAll" = true;
        "ruff.organizeImports" = true;

        "[python]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = true;

          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "charliermarsh.ruff";

          "editor.codeActionsOnSave" = {
            "source.fixAll" = "explicit";
            "source.organizeImports" = "explicit";
          };
        };

        # ------------------------------------------------------------
        # Asociaciones
        # ------------------------------------------------------------

        "files.associations" = {
          "*.nix" = "nix";
          "flake.lock" = "json";
          "*.bib" = "bibtex";
        };
      };
    };
  };

  home.activation.vscodeSettingsWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.config/Code/User/settings.json"

    if [ -L "$settings" ]; then
      cp "$(readlink -f "$settings")" "$settings.tmp"
      rm "$settings"
      mv "$settings.tmp" "$settings"
      chmod 644 "$settings"
    fi
  '';
}
