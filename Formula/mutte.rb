class Mutte < Formula
  desc "Quiet, encrypted, terminal-first chat for Linux and macOS"
  homepage "https://github.com/mutte-me/mutte-client"
  version "0.1.0-alpha.5"
  license "AGPL-3.0-only"

  on_macos do
    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.5/mutte-0.1.0-alpha.5-macos-aarch64.tar.gz"
      sha256 "f791693f6115795eb8578e722ec35d2e0dc6490a9ec9715a4d70ddcfe0df4a99"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.5/mutte-0.1.0-alpha.5-macos-x86_64.tar.gz"
      sha256 "43ceffe138f8b1948bdfdccac3d8ae0d7a81ffd08a9191c86922571b6ab34d91"
    end
  end

  on_linux do
    depends_on "dbus"

    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.5/mutte-0.1.0-alpha.5-linux-aarch64.tar.gz"
      sha256 "fe91885ef6fb9fb07c248218d1e5c85ccf4d67766947b8a5e57bfab9214ac67c"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.5/mutte-0.1.0-alpha.5-linux-x86_64.tar.gz"
      sha256 "8dfe8a6294daa30765ca9391734cbfb353fd28b58d740b57f0215d13a64b7c1d"
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
