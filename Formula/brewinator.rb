class Brewinator < Formula
  desc "Fetch and archive release notes for outdated Homebrew packages"
  homepage "https://github.com/Duracell1989/brewinator"
  url "https://github.com/Duracell1989/brewinator/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "b604aec43ada9cae29c876f9665e8372893085bd10bd12931fbddd6ac1edb8d0"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/brewinator"
  end

  test do
    # Must stay on a path that reads nothing and writes nothing: `brew test`
    # sandboxes the working directory but NOT $HOME, and Foundation's
    # homeDirectoryForCurrentUser reads getpwuid rather than $HOME, so there
    # is no way to point a real run at scratch state. v0.1.0's test ran the
    # binary bare and fetched notes into the tester's actual archive.
    assert_match version.to_s, shell_output("#{bin}/brewinator --version")
    assert_match "--update", shell_output("#{bin}/brewinator --help")
  end
end
