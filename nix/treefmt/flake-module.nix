{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "LICENSE.md";
        programs.nixfmt.enable = pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
        programs.nixfmt.package = pkgs.nixfmt-rfc-style;
        programs.shellcheck.enable = true;
        programs.deno.enable = true;
        programs.ruff.check = true;
        programs.ruff.format = true;
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];

        programs.mypy = {
          enable = pkgs.stdenv.buildPlatform.isLinux;
          directories.".".extraPythonPackages = [
            pkgs.buildbot
            pkgs.buildbot-worker
            pkgs.python3.pkgs.twisted
          ];
        };

        settings.formatter.ruff-check.priority = 1;
        settings.formatter.ruff-format.priority = 2;
      };
    };
}
