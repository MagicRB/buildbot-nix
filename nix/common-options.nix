{ mapIn, mapOut }:
{ lib, ... }@args:
let
  config = mapIn args.config;
in
mapOut {
  authBackend = lib.mkOption {
    type = lib.types.enum [
      "github"
      "gitea"
      "httpbasicauth"
      "oidc"
      "none"
    ];
    default = "github";
    description = ''
      Which OAuth2 backend to use.
    '';
  };

  accessMode = lib.mkOption {
    description = "Controls the access mode for the Buildbot instance. Choose between public (default) or fullyPrivate mode.";
    default = {
      public = { };
    };
    type = lib.types.attrTag {
      public = lib.mkOption {
        type = lib.types.submodule { };
        description = ''
          Default public mode, will allow read only access to anonymous users. Authentication is handled by
          one of the `authBackend's. CAUTION this will leak information about private repos, the instance has
          access to. Information includes, but is not limited to, repository URLs, number and name of checks,
          and build logs
        '';
      };

      fullyPrivate = lib.mkOption {
        description = ''
          Puts the buildbot instance behind `oauth2-proxy' which protects the whole instance. This makes
          buildbot-native authentication unnecessary unless one desires a mode where the team that can access
          the instance read-only is a superset of the the team that can access it read-write.
        '';
        type =
          let
            common = {
              options = {
                cookieSecretFile = lib.mkOption {
                  type = lib.types.path;
                  description = ''
                    Path to a file containing the cookie secret.
                  '';
                };

                clientSecretFile = lib.mkOption {
                  type = lib.types.path;
                  description = ''
                    Path to a file containing the client secret.
                  '';
                };

                clientId = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Client secret used for OAuth2 authentication.
                  '';
                };

                port = lib.mkOption {
                  type = lib.types.port;
                  description = ''
                    Port number at which the `oauth2-proxy' will listen on.
                  '';
                  default = 8020;
                };
              };
            };

            giteaGithub = {
              imports = [
                common
              ];
              options = {
                teams = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = ''
                    A list of teams that should be given access to BuildBot.
                  '';
                  default = [ ];
                };

                users = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = ''
                    A list of users that should be given access to BuildBot.
                  '';
                  default = [ ];
                };
              };
            };
          in
          lib.types.attrTag {
            gitea = lib.mkOption {
              type = lib.types.submodule giteaGithub;
            };

            github = lib.mkOption {
              type = lib.types.submodule giteaGithub;
            };

            keycloak = lib.mkOption {
              type = lib.types.submodule {
                imports = [ common ];

                options = {
                  oidcIssuerUrl = lib.mkOption {
                    type = lib.types.str;
                    description = ''
                      https://<keycloak host>/realms/<your realm>
                    '';
                  };

                  roles = lib.mkOption {
                    type = lib.types.nullOr (lib.types.listOf lib.types.str);
                    description = ''
                      Required realm roles.
                    '';
                  };
                };
              };
            };
          };
      };
    };
  };

  admins = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Users that are allowed to login to buildbot, trigger builds and change settings";
  };

  buildSystems = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Systems that we will be build";
    default = [ ];
    defaultText = "[ pkgs.stdenv.hostPlatform.system ]";
  };

  evalWorkerCount = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = ''
      Number of nix-eval-jobs worker processes. If null, the number of cores is used.
      If you experience memory issues (buildbot-workers going out-of-memory), you can reduce this number.
    '';
  };

  domain = lib.mkOption {
    type = lib.types.str;
    description = "Buildbot domain";
    example = "buildbot.numtide.com";
  };

  gitea = {
    enable = lib.mkEnableOption "Enable Gitea integration" // {
      default = config.authBackend == "gitea";
    };
    instanceUrl = lib.mkOption {
      type = lib.types.str;
      description = "Gitea instance URL";
    };
    topic = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "build-with-buildbot";
      description = ''
        Projects that have this topic will be built by buildbot.
        If null, all projects that the buildbot Gitea user has access to, are built.
      '';
    };
  };

  cachix = {
    enable = lib.mkEnableOption "Enable Cachix integration";

    name = lib.mkOption {
      type = lib.types.str;
      description = "Cachix name";
    };
  };

  niks3 = {
    enable = lib.mkEnableOption "Enable niks3 integration";

    serverUrl = lib.mkOption {
      type = lib.types.str;
      description = "niks3 server URL";
      example = "https://niks3.yourdomain.com";
    };
  };

  github = {
    enable = lib.mkEnableOption "Enable GitHub integration" // {
      default = config.authBackend == "github";
    };
    topic = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "build-with-buildbot";
      description = ''
        Projects that have this topic will be built by buildbot.
        If null, all projects that the buildbot github user has access to, are built.
      '';
    };
  };
}
