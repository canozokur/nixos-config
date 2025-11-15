self: super: {
  ghostty = super.ghostty.overrideAttrs (oldAttrs: {
    # extend old postInstall (if exists) with wrapProgram
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/ghostty --set LIBGL_ALWAYS_SOFTWARE 1
    '';
  });
}
