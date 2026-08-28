class Mutte < Formula
  desc "Quiet, encrypted, terminal-first chat for Linux and macOS"
  homepage "https://mutte.me"
  version "0.1.0-alpha.4"
  license "AGPL-3.0-only"

  on_macos do
    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.4/mutte-0.1.0-alpha.4-macos-aarch64.tar.gz"
      sha256 "5e67870793651eb1989cf99129766c2fbe30bfe224be548509ac2b3f2ddd3c7b"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.4/mutte-0.1.0-alpha.4-macos-x86_64.tar.gz"
      sha256 "ed3afd73eeb51134c4e5ce32e17dc620749ab458fe7021d0dce4e4c11c51f83f"
    end
  end

  on_linux do
    depends_on "dbus"

    on_arm do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.4/mutte-0.1.0-alpha.4-linux-aarch64.tar.gz"
      sha256 "b07d03b9e7f511e1fe22ec1e6b87b4c7fa80e859357e2c2bf66c34d8c6141763"
    end

    on_intel do
      url "https://github.com/mutte-me/mutte-client/releases/download/v0.1.0-alpha.4/mutte-0.1.0-alpha.4-linux-x86_64.tar.gz"
      sha256 "b8a7dea2829f021272bbc746c393ede0a0726c28c1d7b64bec89a0ba812ada39"
    end
  end

  def install
    on_macos do
      bin.install "mutte"
    end

    on_linux do
      libexec.install "mutte"
      (bin/"mutte").write_env_script(
        libexec/"mutte",
        LD_LIBRARY_PATH: Formula["dbus"].opt_lib,
      )
    end
  end

  test do
    assert_match "mutte #{version}", shell_output("#{bin}/mutte --version")
  end
end
