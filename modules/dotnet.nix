{
  config,
  pkgs,
  inputs,
  ...
}:

let
  dotnetCombined = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      dotnet_10.sdk
      dotnet_9.sdk
    ]
  );
  aspnetCombined = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      aspnetcore_10_0-bin
      aspnetcore_9_0
    ]
  );
in
{
  # Set global environment variables for .NET
  environment.sessionVariables.DOTNET_ROOT = "${dotnetCombined}/share/dotnet";

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    dotnetCombined
    aspnetCombined
  ];

  # Ensure Aspire workload is available with the installed .NET SDKs
  system.activationScripts.dotnet-aspire-install.text = ''
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install aspire"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasm-tools"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasm-experimental"
    runuser -l mariogk -c "${dotnetCombined}/bin/dotnet workload install wasi-experimental"
  '';
}
