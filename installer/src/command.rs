pub(crate) trait Command {
    /// The command identifier. Must be unique
    fn id(&self) -> u32;
    /// The command identifier. Must be unique
    fn name(&self) -> &str;
    /// Checks if the command was already installed
    fn is_installed(&self) -> bool;
    /// Executes the necessary installation steps
    fn install(&self);
}

mod nix;

pub(crate) fn get_all_commands() -> Vec<Box<dyn Command>> {
vec![
        Box::new(nix::Nix),
    ]
}

#[cfg(test)]
mod test {
    use super::get_all_commands;

    #[test]
    fn all_commands_have_unique_ids() {
        let commands = get_all_commands();

        let mut unique_ids = std::collections::HashSet::new();

        for command in commands {
            let id = command.id();
            assert!(!unique_ids.contains(&id), "Duplicate ID found: {}", id);
            unique_ids.insert(id);
        }
    }
}
