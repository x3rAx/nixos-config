self: super: {
    mumble = super.mumble.override {
        speechdSupport = true;
        speechd = super.speechd.override {
            withEspeak = false; withPico = true; withFlite = false;
        };
    };
}
