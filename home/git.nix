{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    # userEmail is set via sops-nix secrets or manually

    settings = {
      user.name = "Mario";

      init.defaultBranch = "main";

      core = {
        editor = "code --wait";
        autocrlf = "input";
        whitespace = "fix";
      };

      pull = {
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      fetch = {
        prune = true;
      };

      merge = {
        conflictStyle = "diff3";
      };

      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };

      rebase = {
        autoStash = true;
      };

      # URL shortcuts
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "https://github.com/" = {
          insteadOf = "github:";
        };
      };

      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --oneline --graph --decorate";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
      };
    };

    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"

      # Editors
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.sublime-workspace"

      # Build
      "*.o"
      "*.pyc"
      "__pycache__/"
      "node_modules/"
      "target/"
      "bin/"
      "obj/"

      # Environment
      ".env"
      ".env.local"
      ".envrc"

      # Nix
      "result"
      "result-*"
    ];
  };

  # Delta for better diffs (now separate from programs.git)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side line-numbers decorations";
      syntax-theme = "Dracula";
      plus-style = "syntax #003800";
      minus-style = "syntax #3f0001";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };
      line-numbers = {
        line-numbers-left-style = "cyan";
        line-numbers-right-style = "cyan";
        line-numbers-minus-style = "124";
        line-numbers-plus-style = "28";
      };
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";

      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
      };
    };
  };

  # Lazygit
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        showIcons = true;
        theme = {
          lightTheme = false;
        };
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
    };
  };
}
