{
  lib,
  stdenv,
  fetchurl,
  patchelf,
}:

let
  version = "8.2.0";

  # upstream ships per-platform Go binaries; the arm64 one is a dynamically
  # linked PIE (no NEEDED libs, only the interpreter needs patching), the
  # amd64 one is fully static
  sources = {
    x86_64-linux = {
      arch = "amd64";
      hash = "sha256-EqCk9rPGySa/p1qdWK7jkT/3h8bRB8zATTqhi0wLW9I=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-LhQJKhWScLViUuGlJMFqo299LEuibpTXVEXAZTm+aK4=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "ocis: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "ocis";
  inherit version;

  src = fetchurl {
    url = "https://github.com/owncloud/ocis/releases/download/v${version}/ocis-${version}-linux-${source.arch}";
    inherit (source) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [ patchelf ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/ocis
    # static binaries fail print-interpreter, dynamic ones need the nix loader
    if patchelf --print-interpreter $out/bin/ocis 2>/dev/null; then
      patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} $out/bin/ocis
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://owncloud.dev/ocis/";
    changelog = "https://github.com/owncloud/ocis/releases/tag/v${version}";
    # non-free EULA: https://owncloud.com/ocis-eula/
    license = licenses.unfree;
    platforms = builtins.attrNames sources;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "ocis";
  };
}
