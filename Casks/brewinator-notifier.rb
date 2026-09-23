cask "brewinator-notifier" do
  version "0.12.2"
  sha256 "351a09d3bcd26d54a547df79dd597d0d9a7a075652ba8683036cc2a9afc8ccfa"

  url "https://github.com/Duracell1989/brewinator/releases/download/v#{version}/BrewinatorNotify.zip"
  name "Brewinator Notify"
  desc "Resident notification agent for brewinator - real icon, name, and click target"
  homepage "https://github.com/Duracell1989/brewinator"

  depends_on macos: :sonoma

  app "BrewinatorNotify.app"
  # brewinator (the formula) picks this up automatically once installed - see
  # NotifierSelection in the formula's own source. No plist ships in the
  # release zip; install-agent.sh writes it, and is the only thing here that
  # can load it. Homebrew's declarative install steps run inside a sandbox and
  # launchd refuses job submission from any sandboxed process, so
  # `launchctl bootstrap` fails there with EIO however it is invoked - even
  # under a fully permissive `sandbox-exec` profile (Homebrew/brew#23891).
  # An installer script runs outside that sandbox, so it works here.
  #
  # Installer artifacts run before the app is moved, so the agent is submitted
  # against an executable that is not in place yet: it exits 78 and KeepAlive
  # picks it up about a throttle interval later, once the move lands.
  installer script: {
    executable: "install-agent.sh",
    args:       ["#{appdir}/BrewinatorNotify.app/Contents/MacOS/BrewinatorNotify"],
    sudo:       false,
  }

  uninstall launchctl: "dev.b89.brewinator.notifier"

  zap trash: "~/Library/LaunchAgents/dev.b89.brewinator.notifier.plist"

  caveats do
    <<~EOS
      Brewinator Notify is installed and its agent is loaded; launchd keeps it
      running and relaunches it at login. The first notification it shows will
      trigger a macOS permission prompt - approve it, or check
      System Settings > Notifications for "Brewinator Notify" if none appears.

      brewinator picks it up automatically - no config change needed.
    EOS
  end
end
