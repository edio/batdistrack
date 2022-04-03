{
  description = "Track battery discharge during suspend";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "batdistrack";
        deps = with pkgs; [ bc ];
        script = (pkgs.writeTextFile {
          name = name;
          text = (builtins.readFile ./batdistrack);
          executable = true;
          destination = "/etc/systemd/system-sleep/${name}";
        }).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.batdistrack;
        packages.batdistrack = pkgs.symlinkJoin {
          name = name;
          paths = [ script ] ++ deps;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/etc/systemd/system-sleep/${name} --prefix PATH : $out/bin";
        };
      }
    );
}
