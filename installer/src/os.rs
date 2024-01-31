use std::process::Command;


#[derive(Debug)]
pub struct HostInfo {
    pub os: OS,
    pub session: Option<String>,
}

#[derive(Debug)]
pub(crate) enum OS {
    Linux,
    MacOs,
    Windows,
}

pub fn get_host_information() -> Option<HostInfo> {
    #[cfg(target_os = "linux")]
    {
        let xdg_session = std::env::var("XDG_SESSION_TYPE").ok();

        Some(HostInfo { os: OS::Linux, session: xdg_session })
    }

    #[cfg(target_os = "macos")]
    {
        Some(HostInfo { os: OS::MacOs, session: None })
    }

    #[cfg(target_os = "windows")]
    {
        Some(HostInfo { os: OS::Windows, session: None })
    }

    #[cfg(not(any(target_os = "linux", target_os = "macos", target_os = "windows")))]
    {
        // Unsupported OS, returning None
        None
    }
}

pub fn is_command_available(command: &str) -> bool {
    let output = Command::new("which")
        .arg(command)
        .output()
        .expect("Failed to run which command");

    output.status.success()
}