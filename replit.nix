{ pkgs }: {
	deps = [
    pkgs.swift
		pkgs.ccls
		pkgs.gdb
		pkgs.gnumake
    pkgs.graalvm17-ce
    pkgs.maven
    pkgs.replitPackages.jdt-language-server
    pkgs.replitPackages.java-debug
    pkgs.python3Packages.numpy
	];
}
 