cask "trae-cn" do
  arch arm: "arm64", intel: "x64"
  os macos: "darwin", linux: "linux"

  version "2.3.56916"
  sha256 arm:          "ca9948fd3824bcb156b5a3973fdc31a4a09a5f6c2397e48d9cdbfbfb2cc68060",
         intel:        "dd7eceeeb0e1aafa0b71a2688d7753855e5a4cec33a8e0d3031285543c37a471",
         arm64_linux:  "95f945328f9f57c1e4e08efa96b5b3089dd0f3095d274d666ba19f0a7068ffa7",
         x86_64_linux: "5cc025421213a013af4f5fb831d89de2c21fa4608793a5f62b42f576c70e56b1"

  url_end = on_system_conditional linux: "tar.gz", macos: "dmg"

  url "https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/#{version}/#{os}/Trae_CN-#{os}-#{arch}.#{url_end}"
  name "Trae CN"
  desc "Adaptive AI IDE"
  homepage "https://www.trae.com.cn/"

  on_macos do
    depends_on macos: :monterey

    app "Trae CN.app"

    uninstall launchctl: "cn.trae.ShipIt",
              quit:      "cn.trae.app"

    zap trash: [
      "~/.trae-cn",
      "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/cn.trae.app.sfl*",
      "~/Library/Application Support/Trae CN",
      "~/Library/Caches/cn.trae.app",
      "~/Library/Caches/cn.trae.ShipIt",
      "~/Library/HTTPStorages/cn.trae.app",
      "~/Library/Preferences/ByHost/cn.trae.ShipIt.*.plist",
      "~/Library/Preferences/cn.trae.app.helper.plist",
      "~/Library/Preferences/cn.trae.app.plist",
      "~/Library/Saved Application State/cn.trae.app.savedState",
    ]
  end

  on_linux do
    cask_name = name
    cask_desc = desc

    binary "bin/trae-cn"
    bash_completion "#{staged_path}/resources/completions/bash/trae-cn"
    zsh_completion  "#{staged_path}/resources/completions/zsh/_trae-cn"

    # FIXME: official casks require those from upstream rather then someone imagine
    # those, so we have those here, thanks to ublue taps on bazzite
    desktop_file = "#{staged_path}/trae-cn.desktop"
    url_handler_desktop_file = "#{staged_path}/trae-cn-url-handler.desktop"
    preflight do
      FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
      File.write(desktop_file, <<~EOS)
        [Desktop Entry]
        Name=#{cask_name[0]}
        Comment=#{cask_desc}
        GenericName=Text Editor
        Exec=#{HOMEBREW_PREFIX}/bin/trae-cn %F
        Icon=#{staged_path}/resources/app/resources/linux/code.png
        Type=Application
        StartupNotify=false
        StartupWMClass=Code
        Categories=TextEditor;Development;IDE;
        MimeType=application/x-code-workspace;
        Actions=new-empty-window;
        Keywords=trae-cn;

        [Desktop Action new-empty-window]
        Name=New Empty Window
        Name[cs]=Nové prázdné okno
        Name[de]=Neues leeres Fenster
        Name[es]=Nueva ventana vacía
        Name[fr]=Nouvelle fenêtre vide
        Name[it]=Nuova finestra vuota
        Name[ja]=新しい空のウィンドウ
        Name[ko]=새 빈 창
        Name[ru]=Новое пустое окно
        Name[zh_CN]=新建空窗口
        Name[zh_TW]=開新空視窗
        Exec=#{HOMEBREW_PREFIX}/bin/trae-cn --new-window %F
        Icon=#{staged_path}/resources/app/resources/linux/code.png
      EOS
      File.write(url_handler_desktop_file, <<~EOS)
        [Desktop Entry]
        Name=#{cask_name[0]} - URL Handler
        Comment=#{cask_desc}
        GenericName=Text Editor
        Exec=#{HOMEBREW_PREFIX}/bin/code --open-url %U
        Icon=#{staged_path}/resources/app/resources/linux/code.png
        Type=Application
        NoDisplay=true
        StartupNotify=true
        Categories=Utility;TextEditor;Development;IDE;
        MimeType=x-scheme-handler/trae-cn;
        Keywords=trae-cn;
      EOS
    end

    artifact desktop_file,
             target: "#{Dir.home}/.local/share/applications/trae-cn.desktop"
    artifact url_handler_desktop_file,
             target: "#{Dir.home}/.local/share/applications/trae-cn-url-handler.desktop"
    zap trash: [
      "~/.config/Trae CN",
      "~/.local/share/Trae CN",
      "~/.trae-cn",
    ]
  end

  livecheck do
    url "https://api.trae.ai/icube/api/v1/native/version/trae/cn/latest"
    strategy :json do |json|
      json.dig("data", "manifest", os, "version")
    end
  end

  auto_updates true
end
