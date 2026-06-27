use std::env;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{self, Command};

use serde_json::{json, Value};

const CONFIG_KEY: &str = "KITANA_SDDM_FOCUS_MONITOR";
const DEFAULT_FOCUS_FILE: &str = "/var/lib/kitana/sddm/focus-monitor";

struct Paths {
    kitana_dir: PathBuf,
    config_file: PathBuf,
    focus_file: PathBuf,
}

#[derive(Clone)]
struct MonitorItem {
    name: String,
    description: String,
    selector: String,
    display_name: String,
    active: bool,
    x: i64,
    y: i64,
    id: i64,
}

fn main() {
    match run() {
        Ok(code) => process::exit(code),
        Err(error) => {
            eprintln!("kitana-sddm-monitor: {error}");
            process::exit(1);
        }
    }
}

fn run() -> Result<i32, Box<dyn std::error::Error>> {
    let paths = Paths::new();
    let args: Vec<String> = env::args().skip(1).collect();

    match args.first().map(String::as_str) {
        Some("--json") if args.len() == 1 => {
            print_json(&paths)?;
            Ok(0)
        }
        Some("--get") if args.len() == 1 => {
            println!("{}", configured_selector(&paths));
            Ok(0)
        }
        Some("--set") if args.len() == 2 => {
            set_selector(&paths, &args[1])?;
            Ok(0)
        }
        Some("--clear") if args.len() == 1 => {
            set_selector(&paths, "")?;
            Ok(0)
        }
        Some("-h" | "--help") if args.len() == 1 => {
            usage(io::stdout())?;
            Ok(0)
        }
        None => {
            usage(io::stderr())?;
            Ok(2)
        }
        _ => {
            usage(io::stderr())?;
            Ok(2)
        }
    }
}

impl Paths {
    fn new() -> Self {
        let home = env::var_os("HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from("."));
        let kitana_dir = env::var_os("KITANA_DIR")
            .filter(|value| !value.is_empty())
            .map(PathBuf::from)
            .unwrap_or_else(|| home.join(".local/share/kitana"));
        let focus_file = env::var_os("KITANA_SDDM_FOCUS_MONITOR_FILE")
            .filter(|value| !value.is_empty())
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from(DEFAULT_FOCUS_FILE));

        Self {
            kitana_dir,
            config_file: home.join(".config/kitana/config"),
            focus_file,
        }
    }
}

fn usage(mut output: impl Write) -> io::Result<()> {
    writeln!(
        output,
        "Usage: kitana-sddm-monitor [--json] [--get] [--set SELECTOR] [--clear]\n\n\
Manage the monitor selector used by Kitana's SDDM greeter.\n\n\
Options:\n\
  --json          Print current selector and detected monitors as JSON\n\
  --get           Print the configured selector\n\
  --set SELECTOR  Save a Hyprland monitor selector, preferably desc:...\n\
  --clear         Let SDDM keep Hyprland's default monitor focus"
    )
}

fn configured_selector(paths: &Paths) -> String {
    if let Ok(selector) = env::var(CONFIG_KEY) {
        if !selector.is_empty() {
            return selector;
        }
    }

    if let Ok(content) = fs::read_to_string(&paths.config_file) {
        if let Some(selector) = parse_config_selector(&content) {
            return selector;
        }
    }

    read_first_line(&paths.focus_file).unwrap_or_default()
}

fn parse_config_selector(content: &str) -> Option<String> {
    for line in content.lines() {
        let trimmed = line.trim_start();
        if trimmed.starts_with('#') {
            continue;
        }

        let assignment = trimmed.strip_prefix("export ").unwrap_or(trimmed);
        let Some(value) = assignment
            .strip_prefix(CONFIG_KEY)
            .and_then(|rest| rest.strip_prefix('='))
        else {
            continue;
        };

        return Some(parse_shell_value(value.trim_start()));
    }

    None
}

fn parse_shell_value(value: &str) -> String {
    let mut output = String::new();
    let chars: Vec<char> = value.chars().collect();
    let mut index = 0;

    while index < chars.len() {
        match chars[index] {
            '\'' => {
                index += 1;
                while index < chars.len() && chars[index] != '\'' {
                    output.push(chars[index]);
                    index += 1;
                }
                if index < chars.len() {
                    index += 1;
                }
            }
            '"' => {
                index += 1;
                while index < chars.len() && chars[index] != '"' {
                    if chars[index] == '\\' && index + 1 < chars.len() {
                        index += 1;
                    }
                    output.push(chars[index]);
                    index += 1;
                }
                if index < chars.len() {
                    index += 1;
                }
            }
            '\\' => {
                index += 1;
                if index < chars.len() {
                    output.push(chars[index]);
                    index += 1;
                }
            }
            '#' => break,
            character if character.is_whitespace() => break,
            character => {
                output.push(character);
                index += 1;
            }
        }
    }

    output
}

fn read_first_line(path: &Path) -> Option<String> {
    fs::read_to_string(path)
        .ok()
        .and_then(|content| content.lines().next().map(|line| line.trim().to_string()))
}

fn set_selector(paths: &Paths, selector: &str) -> Result<(), Box<dyn std::error::Error>> {
    if !selector_valid(selector) {
        eprintln!("Invalid SDDM monitor selector");
        process::exit(2);
    }

    write_user_config(paths, selector)?;

    if let Err(error) = write_focus_cache(paths, selector) {
        eprintln!(
            "Saved {}; run kitana-refresh --sddm to deploy it for SDDM. ({error})",
            paths.config_file.display()
        );
    }

    Ok(())
}

fn selector_valid(selector: &str) -> bool {
    selector.len() <= 512 && !selector.contains('\n') && !selector.contains('\r')
}

fn write_user_config(paths: &Paths, selector: &str) -> Result<(), Box<dyn std::error::Error>> {
    let Some(config_dir) = paths.config_file.parent() else {
        return Err("config file has no parent directory".into());
    };
    fs::create_dir_all(config_dir)?;

    if !paths.config_file.exists() {
        let source = paths.kitana_dir.join("config/kitana/config");
        if source.exists() {
            fs::copy(source, &paths.config_file)?;
        } else {
            fs::write(&paths.config_file, "# Kitana user config\n\n")?;
        }
    }

    let content = fs::read_to_string(&paths.config_file).unwrap_or_default();
    let quoted = shell_single_quote(selector);
    let replacement = format!("{CONFIG_KEY}={quoted}");
    let mut output = String::new();
    let mut found = false;

    for line in content.lines() {
        if line_is_selector_assignment(line) {
            if !found {
                output.push_str(&replacement);
                output.push('\n');
                found = true;
            }
        } else {
            output.push_str(line);
            output.push('\n');
        }
    }

    if !found {
        output.push_str(&replacement);
        output.push('\n');
    }

    let tmp = paths
        .config_file
        .with_extension(format!("tmp.{}", process::id()));
    fs::write(&tmp, output)?;
    fs::rename(tmp, &paths.config_file)?;
    Ok(())
}

fn line_is_selector_assignment(line: &str) -> bool {
    let trimmed = line.trim_start();
    let assignment = trimmed.strip_prefix("export ").unwrap_or(trimmed);
    assignment
        .strip_prefix(CONFIG_KEY)
        .and_then(|rest| rest.strip_prefix('='))
        .is_some()
}

fn shell_single_quote(value: &str) -> String {
    format!("'{}'", value.replace('\'', "'\\''"))
}

fn write_focus_cache(paths: &Paths, selector: &str) -> Result<(), Box<dyn std::error::Error>> {
    let mut file = OpenOptions::new()
        .create(true)
        .truncate(true)
        .write(true)
        .open(&paths.focus_file)?;

    if !selector.is_empty() {
        writeln!(file, "{selector}")?;
    }

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(&paths.focus_file, fs::Permissions::from_mode(0o644))?;
    }

    Ok(())
}

fn print_json(paths: &Paths) -> Result<(), Box<dyn std::error::Error>> {
    let selected = configured_selector(paths);
    let deployed = read_first_line(&paths.focus_file).unwrap_or_default();
    let monitors = monitor_items(&hypr_monitors_json(), &selected);
    let cache_writable = focus_cache_writable(&paths.focus_file);
    let monitor_values: Vec<Value> = monitors
        .into_iter()
        .map(|monitor| {
            json!({
                "name": monitor.name,
                "description": monitor.description,
                "selector": monitor.selector,
                "displayName": monitor.display_name,
                "active": monitor.active,
                "x": monitor.x,
                "y": monitor.y,
                "id": monitor.id,
            })
        })
        .collect();

    println!(
        "{}",
        serde_json::to_string(&json!({
            "selector": selected,
            "deployedSelector": deployed,
            "cacheWritable": cache_writable,
            "monitors": monitor_values,
        }))?
    );

    Ok(())
}

fn hypr_monitors_json() -> String {
    match Command::new("hyprctl").args(["monitors", "-j"]).output() {
        Ok(output) if output.status.success() => {
            String::from_utf8_lossy(&output.stdout).to_string()
        }
        _ => "[]".to_string(),
    }
}

fn monitor_items(raw: &str, selected: &str) -> Vec<MonitorItem> {
    let parsed: Value = serde_json::from_str(raw).unwrap_or_else(|_| json!([]));
    let mut items = Vec::new();

    let Some(monitors) = parsed.as_array() else {
        return items;
    };

    for monitor in monitors {
        if monitor
            .get("disabled")
            .and_then(Value::as_bool)
            .unwrap_or(false)
        {
            continue;
        }

        let name = string_field(monitor, "name");
        let description = string_field(monitor, "description");
        let selector = if description.is_empty() {
            name.clone()
        } else {
            format!("desc:{description}")
        };
        let display_name = first_non_empty([&name, &description, &selector]);
        let desc_selector = if description.is_empty() {
            String::new()
        } else {
            format!("desc:{description}")
        };
        let active = !selected.is_empty()
            && (selected == selector || selected == name || selected == desc_selector);

        items.push(MonitorItem {
            name,
            description,
            selector,
            display_name,
            active,
            x: int_field(monitor, "x"),
            y: int_field(monitor, "y"),
            id: int_field(monitor, "id"),
        });
    }

    items.sort_by(|left, right| {
        (left.x, left.y, left.id, &left.display_name).cmp(&(
            right.x,
            right.y,
            right.id,
            &right.display_name,
        ))
    });
    items
}

fn string_field(value: &Value, key: &str) -> String {
    value
        .get(key)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_string()
}

fn int_field(value: &Value, key: &str) -> i64 {
    value.get(key).and_then(Value::as_i64).unwrap_or_default()
}

fn first_non_empty(values: [&str; 3]) -> String {
    values
        .into_iter()
        .find(|value| !value.is_empty())
        .unwrap_or_default()
        .to_string()
}

fn focus_cache_writable(path: &Path) -> bool {
    path.exists() && OpenOptions::new().write(true).open(path).is_ok()
}
