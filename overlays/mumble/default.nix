self: super: {
  mumble = super.mumble.override {
    # Speech support for mumble
    speechdSupport = true;
    speechd = super.speechd.override {
      withEspeak = false;
      withPico = true;
      withFlite = false;
    };
  };
}
