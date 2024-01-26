use std::path::{Path, PathBuf};

use git2::Repository;
use inquire::{validator::Validation, Text};

fn main() {
    println!("Starting dotfiles setup");

    let repository = close_repository();
    todo!("setup symlinks to {:?}", repository);
    todo!("setup nix");
    todo!("setup zsh");
    todo!("install global utilities");
    todo!("install GUI apps");
    todo!("setup terminal configuration");
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
