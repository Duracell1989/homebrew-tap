class Brewinator < Formula
  desc "Fetch and archive release notes for outdated Homebrew packages"
  homepage "https://github.com/Duracell1989/brewinator"
  url "https://github.com/Duracell1989/brewinator/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "cfa1906e3e53744394533dd36662f0b34efd8aa5ccf1c760c0701cd663adc6df"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/brewinator"
  end

  test do
    # --help/--version don't reliably intercept on the beta toolchain this was
    # built against (ArgumentParser's AsyncParsableCommand check is broken),
    # so verification uses real first-run behavior instead: Homebrew's test
    # sandbox points $HOME at a scratch dir, so no config exists, and
    # brewinator prints a friendly message and exits 1.
    output = shell_output("#{bin}/brewinator 2>&1", 1)
    assert_match "No config found at", output
    assert_match "archiveDirectory", output
  end
end
