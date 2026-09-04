cask "brewinator-notifier" do
  version "0.8.0"
  sha256 "02846f9b6bf27d08bed2b1869c658a528855223a2445035cc51f26aced0969ce"

  url "https://github.com/Duracell1989/brewinator/releases/download/v#{version}/BrewinatorNotify.zip"
  name "Brewinator Notify"
  desc "Resident notification agent for brewinator - real icon, name, and click target"
  homepage "https://github.com/Duracell1989/brewinator"

  depends_on macos: :sonoma

  app "BrewinatorNotify.app"

  # brewinator (the formula) picks this up automatically once installed - see
  # NotifierSelection in the formula's own source. No plist ships in the
  # release zip; it's written here so the cask stays a single download.
  postflight do
    plist_path = "#{Dir.home}/Library/LaunchAgents/dev.b89.brewinator.notifier.plist"
    File.write(plist_path, <<~EOS)
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
    system_command "/bin/launchctl",
                   args: ["bootstrap", "gui/#{Process.uid}", plist_path]
  end

  uninstall launchctl: "dev.b89.brewinator.notifier"

  zap trash: "~/Library/LaunchAgents/dev.b89.brewinator.notifier.plist"

  caveats do
    <<~EOS
      Brewinator Notify is now running in the background and will start
      automatically at login. The first notification it shows will trigger a
      macOS permission prompt - approve it, or check System Settings >
      Notifications for "Brewinator Notify" if none appears.

      brewinator picks it up automatically on the next run - no config change
      needed.
    EOS
  end
end
