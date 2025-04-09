{...}: {
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap"; # 卸载未声明的包（可选）
  homebrew.onActivation.upgrade = true;

  # 声明要安装的 Homebrew 软件
  homebrew.brews = [
    "wget"
    "htop"
    "mas" # macOS App Store CLI
    "uv"
    "pnpm"
  ];

  # 安装 GUI 应用（Cask）
  homebrew.casks = [
    # "google-chrome"
    # "visual-studio-code"
    "orbstack"
    "snipaste"
    "kitty"
  ];

  # 安装 Mac App Store 应用（需 `mas`）
  homebrew.masApps = {
    # "Xcode" = 497799835; # 通过 `mas search Xcode` 获取 ID
    # "Telegram" = 747648890;
  };

  # 添加自定义 Homebrew Tap
  homebrew.taps = [
    "felixkratz/formulae"
  ];
}
