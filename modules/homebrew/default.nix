{...}: {
  # 设置主用户（必须与你的用户名一致）
  system.primaryUser = "kemengjian";
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.cleanup = "zap"; # 卸载未声明的包（可选）
  homebrew.onActivation.upgrade = false;

  # 声明要安装的 Homebrew 软件
  homebrew.brews = [
    "wget"
    "htop"
    "mas" # macOS App Store CLI
    "uv"
    "pnpm"

    "lua"
    "luarocks"

    "lazygit"
    "ripgrep"
    "fd"
    "love"
    "neovim"
  ];

  # 安装 GUI 应用（Cask）
  homebrew.casks = [
    # "google-chrome"
    # "visual-studio-code"
    "orbstack"
    "snipaste"
    "kitty"

    # 用于显示按键，方便录屏
    "keycastr"

    "font-hack-nerd-font"
    # 翻译软件
    "easydict"
    # app卸载软件
    "appcleaner"
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
