self: super: {
    wooting-udev-rules = super.wooting-udev-rules.overrideAttrs (oldAttrs: {
        src = [ ./wooting.rules ];
    });
}
