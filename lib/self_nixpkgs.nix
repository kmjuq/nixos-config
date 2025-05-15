{lib, ...}: {
  # Generate an attribute set from a list.
  #
  #   lib.genAttrs [ "foo" "bar" ] (name: "x_" + name)
  #     => { foo = "x_foo"; bar = "x_bar"; }
  listToAttrs = lib.genAttrs;
}
