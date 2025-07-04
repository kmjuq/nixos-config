{...}: {
  # 设置主用户（必须与你的用户名一致）
  system.primaryUser = "kemengjian";
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.cleanup = "zap"; # 卸载未声明的包（可选）
  homebrew.onActivation.upgrade = false;

  # 声明要安装的 Homebrew 软件
  homebrew.brews = [
    "mas" # macOS App Store CLI

    "lua"
    "luarocks"

    "yabai"
    "skhd"
    "sketchybar"
  ];

  # 安装 GUI 应用（Cask）
  homebrew.casks = [
    # "google-chrome"
    # "visual-studio-code"
    # mac 平台 docker k8s平台
    "orbstack"
    # 截图贴图
    "snipaste"

    # 用于显示按键，方便录屏
    "keycastr"

    # 翻译软件
    "easydict"
    # app卸载软件
    "appcleaner"
    # love 物理引擎
    "love"

    # 字体
    "font-hack-nerd-font"
  ];

  # 安装 Mac App Store 应用（需 `mas`）
  homebrew.masApps = {
    # "Xcode" = 497799835; # 通过 `mas search Xcode` 获取 ID
    # "Telegram" = 747648890;
  };

  # 添加自定义 Homebrew Tap
  homebrew.taps = [
    "FelixKratz/formulae"
    "nikitabobko/tap"
    "koekeishiya/formulae"
  ];
}
