class Mutte < Formula
  desc "Quiet, encrypted, terminal-first chat for Linux and macOS"
  homepage "https://github.com/mutte-me/mutte-client"
  version "0.1.0-alpha.7"
  license "AGPL-3.0-only"

  on_macos do
    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.7/mutte-0.1.0-alpha.7-macos-aarch64.tar.gz"
      sha256 "5751b295e02e8b9886e81a04a2115b7ea165e4b4666f95f44760b235d54e661a"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.7/mutte-0.1.0-alpha.7-macos-x86_64.tar.gz"
      sha256 "bd9c91221bcbddc0beea6c13f2e9b558c3f1c87a84df4a09193dc4a36516dec8"
    end
  end

  on_linux do
    depends_on "dbus"

    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.7/mutte-0.1.0-alpha.7-linux-aarch64.tar.gz"
      sha256 "6fcb292f8941bbf39a02a62deeea74bc7463548014f8b23713b12af8e8ae4935"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.7/mutte-0.1.0-alpha.7-linux-x86_64.tar.gz"
      sha256 "2ebd314744238b87e1814e2014aa1a2b212b9e6fb57aa48e032f8e8061b04645"
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
