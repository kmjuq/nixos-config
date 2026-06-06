{extraArgs, ...}: {
  # 设置主用户（必须与你的用户名一致）
  system.primaryUser = "${extraArgs.user.name}";
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = false;
  homebrew.onActivation.cleanup = "zap"; # 卸载未声明的包（可选）
  homebrew.onActivation.upgrade = false;

  # 声明要安装的 Homebrew 软件
  homebrew.brews = [
    "mas" # macOS App Store CLI

    "lua"
    "luarocks"

    # 平铺窗口管理器
    "yabai"
    "skhd"
    "sketchybar"

    "go"
    "pnpm"
    "uv"
    "fnm"

    # ManimCE
    "cairo" 
    "pkg-config"
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
    # 字体
    "font-hack-nerd-font"
    # 记谱软件
    "musescore"
    # 远程桌面
    "rustdesk"
    # 局域网文件传输
    "localsend"
    # 压缩软件
    "keka"
    # MacTex
    "mactex-no-gui"

    "claude-code"
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
