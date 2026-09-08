cask "brewinator-notifier" do
  version "0.9.0"
  sha256 "b204b8a8c5f504826d29a2bd506cb94371a039bf666db7a1dc9ec0e0ac78ef79"

  url "https://github.com/Duracell1989/brewinator/releases/download/v#{version}/BrewinatorNotify.zip"
  name "Brewinator Notify"
  desc "Resident notification agent for brewinator - real icon, name, and click target"
  homepage "https://github.com/Duracell1989/brewinator"

  depends_on macos: :sonoma

  app "BrewinatorNotify.app"

  # brewinator (the formula) picks this up automatically once installed - see
  # NotifierSelection in the formula's own source. No plist ships in the
  # release zip; it's written here so the cask stays a single download.
  #
  # Writing it is all these steps can do. Install steps run inside a sandbox,
  # and launchd refuses job submission from any sandboxed process, so
  # `launchctl bootstrap` fails here with EIO however it is invoked - even a
  # fully permissive `sandbox-exec` profile does (Homebrew/brew#23891).
  #
  # An `installer script:` with `sudo: false` would run unsandboxed and could
  # bootstrap - the maintainer reply on that issue names it as the only route.
  # Not taken here: the script has to ship inside the notarized zip, and
  # `Artifact::Installer` runs ahead of `Artifact::App`, so the agent would be
  # bootstrapped against an executable not yet in /Applications.
  #
  # brewinator loads the agent itself on its next run; see
  # NotifierAgentActivation.
  postflight_steps do
    write_file "Library/LaunchAgents/dev.b89.brewinator.notifier.plist", <<~EOS, base: :home
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>dev.b89.brewinator.notifier</string>
        <key>ProgramArguments</key>
        <array>
          <string>/Applications/BrewinatorNotify.app/Contents/MacOS/BrewinatorNotify</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProcessType</key>
        <string>Interactive</string>
      </dict>
      </plist>
    EOS
  end

  uninstall launchctl: "dev.b89.brewinator.notifier"

  zap trash: "~/Library/LaunchAgents/dev.b89.brewinator.notifier.plist"

  caveats do
    <<~EOS
      Brewinator Notify is installed. brewinator starts it on its next run,
      after which launchd keeps it running and relaunches it at login. The
      first notification it shows will trigger a macOS permission prompt -
      approve it, or check System Settings > Notifications for
      "Brewinator Notify" if none appears.

      brewinator picks it up automatically - no config change needed.
    EOS
  end
end
