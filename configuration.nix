  { config, lib, pkgs, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball { config = config.nixpkgs.config; };
  nomadmb = pkgs.callPackage /home/nixpi/nomadmb.nix { inherit (pkgs) python312; };


  customPython = unstable.python312.withPackages (ps: with ps; [
    rns
    lxmf
    nomadnet
  ]);

  
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  # Ensure you're using unstable in your environment
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Make sure the NIX_PATH is set to use nixos-unstable
  environment.variables = {
    NIX_PATH = lib.mkForce "nixpkgs=${unstableTarball}:nixos-config=/etc/nixos/configuration.nix";
  };


  # Minimal set of system packages from unstable
  environment.systemPackages = with unstable; [
    firefox
    nano
    git
    vim
    curl
    wget
    htop
    neofetch
    tmux
    nomadmb
    python312Packages.rns
    python312Packages.nomadnet
    customPython
    tailscale 
  ];


  services.openssh.enable = true;


# create a oneshot job to authenticate to Tailscale
systemd.services.tailscale-autoconnect = {
  description = "Automatic connection to Tailscale";

  # make sure tailscale is running before trying to connect to tailscale
  after = [ "network-pre.target" "tailscale.service" ];
  wants = [ "network-pre.target" "tailscale.service" ];
  wantedBy = [ "multi-user.target" ];

  # set this service as a oneshot job
  serviceConfig.Type = "oneshot";

  # have the job run this shell script
  script = with pkgs; ''
    # wait for tailscaled to settle
    sleep 2

    # check if we are already authenticated to tailscale
    status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
    if [ $status = "Running" ]; then # if so, then do nothing
      exit 0
    fi

    # otherwise authenticate with tailscale
    ${tailscale}/bin/tailscale up -authkey tskey-auth-
  '';
};



  # Enable and configure Tailscale
  services.tailscale = {
    enable = true;
  };


  networking = {
    hostName = "nixpi";
    networkmanager.enable = true;   # Manages your WiFi connections
    interfaces.usb0.useDHCP = true; # In case you use USB Ethernet
  };

  # Time and locale configuration
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Create a normal user and assign privileges
  users.users.nixpi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];  # Allow the user to use `sudo`
    initialPassword = "nixpi";    # You should change this after initial setup
  };

  system.stateVersion = "24.05";  # Make sure this matches the NixOS version you're using

  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow installation of non-open-source software if needed
  nixpkgs.config.allowUnfree = true;
 
  # Optionally, a service to fetch the latest configuration from GitHub
#  systemd.services.fetch-configuration = {
#    description = "Fetch the configuration from GitHub";
#    after = [ "network-online.target" ];
#    wantedBy = [ "multi-user.target" ];
#    script = ''
#      cd /etc/nixos
#      /run/current-system/sw/bin/git init
#      if ! /run/current-system/sw/bin/git remote | grep -q origin; then
#        /run/current-system/sw/bin/git remote add origin https://github.com/yourusername/yourrepo.git
#      fi
#      /run/current-system/sw/bin/git fetch origin
#      /run/current-system/sw/bin/git checkout -f origin/main -- configuration.nix
#    '';
#  };
}
