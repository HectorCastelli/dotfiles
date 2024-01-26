use std::process::Command;

pub(crate) fn install_nix() {
    println!("Installing nix package manager");

    if Command::new("nix").status().is_ok() {
        println!("Already installed. Moving on...")
    }
}
