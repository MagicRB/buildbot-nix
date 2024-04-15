{ pkgs, ... }:
{
  services.buildbot-nix.master = {
    enable = true;
    # Domain name under which the buildbot frontend is reachable
    domain = "buildbot2.thalheim.io";
    # The workers file configures credentials for the buildbot workers to connect to the master.
    # "name" is the configured worker name in services.buildbot-nix.worker.name of a worker
    # (defaults to the hostname of the machine)
    # "pass" is the password for the worker configured in `services.buildbot-nix.worker.workerPasswordFile`
    # "cores" is the number of cpu cores the worker has.
    # The number must match as otherwise potentially not enought buildbot-workers are created.
    workersFile = pkgs.writeText "workers.json" ''
      [
        { "name": "eve", "pass": "XXXXXXXXXXXXXXXXXXXX", "cores": 16 }
      ]
    '';
    github = {
      # Github user used as a CI identity
      user = "mic92-buildbot";
      # Github token of the same user
      tokenFile = pkgs.writeText "github-token" "ghp_000000000000000000000000000000000000";
      # A random secret used to verify incoming webhooks from GitHub
      # buildbot-nix will set up a webhook for each project in the organization
      webhookSecretFile = pkgs.writeText "webhookSecret" "00000000000000000000";
      # Either create a GitHub app or an OAuth app
      # After creating the app, press "Generate a new client secret" and fill in the client ID and secret below
      oauthId = "aaaaaaaaaaaaaaaaaaaa";
      oauthSecretFile = pkgs.writeText "oauthSecret" "ffffffffffffffffffffffffffffffffffffffff";
      # Users in this list will be able to reload the project list.
      # All other user in the organization will be able to restart builds or evaluations.
      admins = [ "Mic92" ];
      # All github projects with this topic will be added to buildbot.
      # One can trigger a project scan by visiting the Builds -> Builders page and looking for the "reload-github-project" builder.
      # This builder has a "Update Github Projects" button that everyone in the github organization can use.
      topic = "buildbot-mic92";
    };
    # optional expose latest store path as text file
    # outputsPath = "/var/www/buildbot/nix-outputs";

    # optional nix-eval-jobs settings
    # evalWorkerCount = 8; # limit number of concurrent evaluations
    # evalMaxMemorySize = "2048"; # limit memory usage per evaluation

    # optional cachix
    #cachix = {
    #  name = "my-cachix";
    #  # One of the following is required:
    #  signingKey = "/var/lib/secrets/cachix-key";
    #  authToken = "/var/lib/secrets/cachix-token";
    #};
  };

  # Optional: Enable acme/TLS in nginx (recommended)
  #services.nginx.virtualHosts.${config.services.buildbot-nix.master.domain} = {
  #  forceSSL = true;
  #  useACME = true;
  #};
}