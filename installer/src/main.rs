use std::path::{Path, PathBuf};
use git2::Repository;
use inquire::{validator::Validation, Text};

mod nix;
use paris::Logger;


fn main() {
    println!("Starting dotfiles setup");

    let repository = close_repository();
    setup_symlinks(&repository);
    nix::install_nix();
    todo!("setup zsh");
    todo!("install global utilities");
    todo!("install GUI apps");
    todo!("setup terminal configuration");
}

fn setup_symlinks(repository: &PathBuf) {
    println!("Setting up symbolic links");

    // TODO: Move this to each application and manage individually

    // rm -rf "$HOME/.config"
    // ln -sf "$dotfiles/.config" "$HOME/.config"

    // ln -sf "$dotfiles/shell/.zshrc" "$HOME/.zshrc"
    // ln -sf "$dotfiles/shell/.zshenv" "$HOME/.zshenv"

    // ln -sf "$dotfiles/home/.gitconfig" "$HOME/.gitconfig"

}

fn close_repository() -> PathBuf {
    println!("Cloning dotfiles repository");

    let validator = |input: &str| {
        if Path::new(input).exists() {
            Ok(Validation::Invalid(
                "This cannot be an existing directory".into(),
            ))
        } else {
            Ok(Validation::Valid)
        }
    };

    let path = Text::new("Where should we save the repository?")
        .with_default("./dotfiles")
        .with_validator(validator)
        .prompt()
        .expect("An error happened when choosing the clone location.");

    match Repository::clone("https://github.com/HectorCastelli/dotfiles/", &path) {
        Ok(repo) => Path::new(&path).to_path_buf(),
        Err(e) => panic!("Failed to clone repository: {}", e),
    }
}
