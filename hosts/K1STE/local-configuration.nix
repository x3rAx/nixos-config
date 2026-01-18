{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.hosts = {
    "10.194.60.93" = ["ynh.test"];
    # "10.194.60.37" = ["myblog.test" "blog1.ynh.test" "blog2.ynh.test"];
  };
}
