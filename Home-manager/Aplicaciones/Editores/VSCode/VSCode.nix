{
  pkgs,
  lib,
  ...
}: let
  flakePath = "/home/bin/.GitHub/NixOS-Dotfiles";
  ltexLs = pkgs.ltex-ls-plus;
in {
  home.packages = with pkgs; [
    nixd
    nixfmt
    ruff
    typst
    typstyle
    ltexLs
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        # Nix
        jnoortheen.nix-ide
        # Typst
        myriad-dreamin.tinymist
        # Corrección gramatical/prosa científica
        ltex-plus.vscode-ltex-plus
        # Python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy
        charliermarsh.ruff
        # LaTeX
        james-yu.latex-workshop
      ];

      userSettings = {
        # Privacidad y reproducibilidad.
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;

        # Editor general.
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

        # Archivos.
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "files.autoSave" = "off";
        "files.exclude" = {
          "**/.git" = true;
          "**/.direnv" = true;
          "**/result" = true;
          "**/result-*" = true;
          "**/.typst-cache" = true;
          "**/build" = false;
          "**/*.aux" = true;
          "**/*.fls" = true;
          "**/*.fdb_latexmk" = true;
          "**/*.synctex.gz" = true;
          "**/*.log" = true;
        };

        "search.exclude" = {
          "**/.git" = true;
          "**/.direnv" = true;
          "**/result" = true;
          "**/result-*" = true;
          "**/.typst-cache" = true;
          "**/build" = true;
          "**/*.aux" = true;
          "**/*.fls" = true;
          "**/*.fdb_latexmk" = true;
          "**/*.synctex.gz" = true;
          "**/*.log" = true;
        };

        # Nix.
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd = {
            formatting.command = ["nixfmt"];
            options = {
              nixos.expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.PC.options";
              home-manager.expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.PC.options.home-manager.users.type.getSubOptions []";
            };
          };
        };

        "[nix]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

        # Typst / Tinymist.
        "tinymist.exportPdf" = "onSave";
        "tinymist.outputPath" = "$root/build/$dir/$name";
        "tinymist.formatterMode" = "typstyle";
        "tinymist.formatterPrintWidth" = 100;
        "tinymist.formatterProseWrap" = false;
        "tinymist.lint.enabled" = true;
        "tinymist.lint.when" = "onSave";
        "tinymist.preview.refresh" = "onType";
        "tinymist.preview.scrollSync" = "onSelectionChange";
        "tinymist.systemFonts" = true;
        "tinymist.projectResolution" = "lockDatabase";

        "[typst]" = {
          "editor.wordWrap" = "bounded";
          "editor.wordWrapColumn" = 100;
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "myriad-dreamin.tinymist";
        };

        # LTeX+.
        "ltex.ltex-ls.path" = "${ltexLs}";
        "ltex.enabled" = [
          "typst"
          "markdown"
          "bibtex"
          "latex"
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
          "es-AR" = [];
          "en-US" = [];
          "en-GB" = [];
        };
        "ltex.disabledRules" = {
          "es-AR" = [];
          "en-US" = [];
          "en-GB" = [];
        };
        "ltex.hiddenFalsePositives" = {
          "es-AR" = [];
          "en-US" = [];
          "en-GB" = [];
        };

        # Python.
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

        # LaTeX Workshop.
        "latex-workshop.latex.tools" = [
          {
            name = "latexmk";
            command = "latexmk";
            args = [
              "-synctex=1"
              "-interaction=nonstopmode"
              "-file-line-error"
              "-pdf"
              "%DOC%"
            ];
          }
        ];
        "latex-workshop.latex.recipes" = [
          {
            name = "latexmk";
            tools = ["latexmk"];
          }
        ];
        "latex-workshop.latex.build.trigger" = "save";
        "latex-workshop.view.pdf.viewer" = "tab";
        "latex-workshop.pdf.view.center" = true;
        "latex-workshop.message.information.show" = false;
        "latex-workshop.message.warning.show" = false;
        "latex-workshop.latex.autoBuild.run" = "never";
        "latex-workshop.latex.clean.subfolder.enabled" = true;
        "latex-workshop.latex.clean.method" = "glob";
        "latex-workshop.latex.clean.fileTypes" = [
          "*.aux"
          "*.bbl"
          "*.blg"
          "*.idx"
          "*.ind"
          "*.lof"
          "*.lot"
          "*.out"
          "*.toc"
          "*.acn"
          "*.acr"
          "*.alg"
          "*.glg"
          "*.glo"
          "*.gls"
          "*.fls"
          "*.log"
          "*.fdb_latexmk"
          "*.synctex.gz"
        ];
        "latex-workshop.synctex.afterBuild.enabled" = true;

        "[latex]" = {
          "editor.wordWrap" = "bounded";
          "editor.wordWrapColumn" = 100;
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
          "editor.formatOnSave" = false;
        };

        "files.associations" = {
          "*.nix" = "nix";
          "flake.lock" = "json";
          "*.typ" = "typst";
          "*.bib" = "bibtex";
          "*.tex" = "latex";
        };
      };
    };
  };

  home.activation.vscodeSettingsWritable = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings="$HOME/.config/Code/User/settings.json"
    if [ -L "$settings" ]; then
      cp "$(readlink -f "$settings")" "$settings.tmp"
      rm "$settings"
      mv "$settings.tmp" "$settings"
      chmod 644 "$settings"
    fi
  '';
}
