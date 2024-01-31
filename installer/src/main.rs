use command::get_all_commands;

mod command;
mod os;

fn main() {
    if let Some(host_info) = os::get_host_information() {
        println!("Host information: {:#?}", host_info);
        start_install()
    } else {
        println!("Unsupported operating system");
    }
}


fn start_install() {
    let mut commands = get_all_commands();

    // Sort commands numerically by ID
    commands.sort_by(|a, b| a.id().cmp(&b.id()));

    // Execute commands sequentially
    for command in commands.iter() {
        println!("Installing {}:", command.name());
        if !command.is_installed() {
            command.install();
        }
        println!("Already installed. Skipping.");
        // TODO: Implement update functionality
    }
}