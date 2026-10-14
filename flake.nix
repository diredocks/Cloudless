{
  description = "A simple weather app for seniors";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        android_sdk.accept_license = true;
        allowUnfree = true;
      };
    };

    androidSdk =
      (pkgs.androidenv.composeAndroidPackages {
        # Pinned to the versions Flutter expects (see flutter_tools FlutterExtension.kt):
        # compileSdk=36, build-tools=36.0.0, ndk=28.2.13676358
        platformVersions = ["36"];
        buildToolsVersions = ["36.0.0"];
        platformToolsVersion = "latest";
        cmdLineToolsVersion = "latest";
        ndkVersions = ["28.2.13676358"];
        includeEmulator = false;
        includeNDK = true;
      }).androidsdk;

    sdkPath = "${androidSdk}/libexec/android-sdk";
    jdk = pkgs.jdk17;
  in {
    formatter.${system} = pkgs.alejandra;

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.flutter
        jdk
        androidSdk
        pkgs.android-tools
        pkgs.git
      ];

      JAVA_HOME = "${jdk}";
      ANDROID_HOME = sdkPath;
      ANDROID_SDK_ROOT = sdkPath;

      shellHook = ''
        export PATH="$ANDROID_HOME/platform-tools:$PATH"
      '';
    };
  };
}
