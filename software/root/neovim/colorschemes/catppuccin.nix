{
  programs.nixvim.colorschemes.catppuccin.settings = {
    
    color_overrides = {
      mocha = {
        base = "#1e1e2f";
      };
    };

    disable_underline = true;
    
    flavour = "mocha";
    
    integrations = {
      cmp = true;
      gitsigns = true;
      mini = {
        enabled = true;
        indentscope_color = "";
      };
      notify = true;
      nvimtree = true;
      treesitter = true;
    };
    
    styles = {
      booleans = [
        "bold"
        "italic"
      ];
      conditionals = [
        "bold"
      ];
    };
    
    term_colors = true;
  };

}
