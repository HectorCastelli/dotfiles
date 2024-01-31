use crate::os::is_command_available;

use super::Command;

pub(crate) struct Nix;
impl Command for Nix {
    fn id(&self) -> u32 {
        1
    }

    fn name(&self) -> &str {
        "nix-shell"
    }

    fn is_installed(&self) -> bool {
        is_command_available("nix")
    }

    fn install(&self) {
        println!("Installing nix")
    }
}