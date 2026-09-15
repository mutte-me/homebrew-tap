class Mutte < Formula
  desc "Quiet, encrypted, terminal-first chat for Linux and macOS"
  homepage "https://github.com/mutte-me/mutte-client"
  version "0.1.0-alpha.6"
  license "AGPL-3.0-only"

  on_macos do
    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.6/mutte-0.1.0-alpha.6-macos-aarch64.tar.gz"
      sha256 "b5082095a57baf9357c8770a4772c111ffea7f944262d660e541e7236e0ff5cf"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.6/mutte-0.1.0-alpha.6-macos-x86_64.tar.gz"
      sha256 "ec08afa1f8001ec4e99514c4310116255dd021b19be5b7c149d641ed91a319e1"
    end
  end

  on_linux do
    depends_on "dbus"

    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.6/mutte-0.1.0-alpha.6-linux-aarch64.tar.gz"
      sha256 "a0d6046fe80f2e16df115a1d027e6675dbc0272258527a6ed4201ca5ddb7728e"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.6/mutte-0.1.0-alpha.6-linux-x86_64.tar.gz"
      sha256 "c5792736a6d5ad7810f1e75e199dfd13ad698754ba5ed065b3de9b135817afec"
    end
  end

  def install
    if OS.mac?
      bin.install "mutte"
    else
      libexec.install "mutte"
      (bin/"mutte").write_env_script(
        libexec/"mutte",
        LD_LIBRARY_PATH: formula_opt_lib("dbus"),
      )
    end
  end

  test do
    assert_match "mutte #{version}", shell_output("#{bin}/mutte --version")
  end
end
