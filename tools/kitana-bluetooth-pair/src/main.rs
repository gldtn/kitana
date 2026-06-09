use std::collections::HashMap;
use std::process;
use std::time::Duration;

use anyhow::{anyhow, Context, Result};
use clap::Parser;
use tokio::time::sleep;
use zbus::{fdo, interface, Connection, Proxy};
use zvariant::{ObjectPath, OwnedObjectPath, OwnedValue};

const AGENT_PATH: &str = "/org/kitana/bluetooth/agent";
const AGENT_CAPABILITY: &str = "KeyboardDisplay";
const BLUEZ: &str = "org.bluez";
const DEVICE_IFACE: &str = "org.bluez.Device1";
const AGENT_MANAGER_IFACE: &str = "org.bluez.AgentManager1";
const OBJECT_MANAGER_IFACE: &str = "org.freedesktop.DBus.ObjectManager";

type ManagedObjects = HashMap<OwnedObjectPath, HashMap<String, HashMap<String, OwnedValue>>>;

#[derive(Parser)]
#[command(about = "Pair and connect one Bluetooth device using a temporary BlueZ agent.")]
struct Args {
    /// Bluetooth device address, for example 2C:18:09:DD:03:B9
    address: String,

    /// Pairing timeout in seconds
    #[arg(long, default_value_t = 60)]
    timeout: u64,
}

struct Agent;

#[interface(name = "org.bluez.Agent1")]
impl Agent {
    async fn release(&self) -> fdo::Result<()> {
        Ok(())
    }

    async fn request_pin_code(&self, device: OwnedObjectPath) -> fdo::Result<String> {
        log(format!("pin code requested for {device}"));
        Ok("0000".to_string())
    }

    async fn display_pin_code(&self, device: OwnedObjectPath, pincode: String) -> fdo::Result<()> {
        log(format!("DisplayPinCode: ({device}, {pincode})"));
        Ok(())
    }

    async fn request_passkey(&self, device: OwnedObjectPath) -> fdo::Result<u32> {
        log(format!("passkey requested for {device}"));
        Ok(0)
    }

    async fn display_passkey(
        &self,
        device: OwnedObjectPath,
        passkey: u32,
        entered: u16,
    ) -> fdo::Result<()> {
        log(format!("DisplayPasskey: ({device}, {passkey}, {entered})"));
        Ok(())
    }

    async fn request_confirmation(&self, device: OwnedObjectPath, passkey: u32) -> fdo::Result<()> {
        log(format!(
            "accepted RequestConfirmation: ({device}, {passkey})"
        ));
        Ok(())
    }

    async fn request_authorization(&self, device: OwnedObjectPath) -> fdo::Result<()> {
        log(format!("accepted RequestAuthorization: ({device})"));
        Ok(())
    }

    async fn authorize_service(&self, device: OwnedObjectPath, uuid: String) -> fdo::Result<()> {
        log(format!("accepted AuthorizeService: ({device}, {uuid})"));
        Ok(())
    }

    async fn cancel(&self) -> fdo::Result<()> {
        log("pairing cancelled by BlueZ");
        Ok(())
    }
}

struct RegisteredAgent<'a> {
    connection: &'a Connection,
    agent_registered: bool,
    object_registered: bool,
}

impl<'a> RegisteredAgent<'a> {
    async fn register(connection: &'a Connection) -> Result<Self> {
        connection
            .object_server()
            .at(AGENT_PATH, Agent)
            .await
            .context("registering Agent1 object")?;

        let mut agent = Self {
            connection,
            agent_registered: false,
            object_registered: true,
        };

        let manager = Proxy::new(connection, BLUEZ, "/org/bluez", AGENT_MANAGER_IFACE)
            .await
            .context("creating BlueZ AgentManager1 proxy")?;
        let agent_path = ObjectPath::try_from(AGENT_PATH).context("building Agent1 object path")?;

        let _: () = manager
            .call("RegisterAgent", &(agent_path, AGENT_CAPABILITY))
            .await
            .context("registering BlueZ pairing agent")?;
        agent.agent_registered = true;

        let agent_path = ObjectPath::try_from(AGENT_PATH).context("building Agent1 object path")?;
        if let Err(error) = manager
            .call::<_, _, ()>("RequestDefaultAgent", &(agent_path))
            .await
        {
            log(format!("could not become default agent: {error}"));
        }

        Ok(agent)
    }

    async fn unregister(&mut self) {
        if self.agent_registered {
            match Proxy::new(self.connection, BLUEZ, "/org/bluez", AGENT_MANAGER_IFACE).await {
                Ok(manager) => {
                    let agent_path = match ObjectPath::try_from(AGENT_PATH) {
                        Ok(path) => path,
                        Err(error) => {
                            log(format!(
                                "could not build agent path for unregister: {error}"
                            ));
                            self.agent_registered = false;
                            return;
                        }
                    };

                    if let Err(error) = manager
                        .call::<_, _, ()>("UnregisterAgent", &(agent_path))
                        .await
                    {
                        log(format!("could not unregister agent: {error}"));
                    }
                }
                Err(error) => log(format!(
                    "could not create AgentManager1 proxy for unregister: {error}"
                )),
            }
            self.agent_registered = false;
        }

        if self.object_registered {
            if let Err(error) = self
                .connection
                .object_server()
                .remove::<Agent, _>(AGENT_PATH)
                .await
            {
                log(format!("could not remove Agent1 object: {error}"));
            }
            self.object_registered = false;
        }
    }
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    let address = args.address.to_uppercase();
    let exit_code = match run(address, args.timeout).await {
        Ok(code) => code,
        Err(error) => {
            log(format!("{error:#}"));
            1
        }
    };

    process::exit(exit_code);
}

async fn run(address: String, timeout_seconds: u64) -> Result<i32> {
    let connection = Connection::system()
        .await
        .context("connecting to system D-Bus")?;

    let Some(device_path) = find_device_path(&connection, &address).await? else {
        log(format!("device not found: {address}"));
        return Ok(1);
    };

    let mut agent = RegisteredAgent::register(&connection).await?;
    let operation = pair_trust_and_connect(&connection, device_path, address.clone());
    tokio::pin!(operation);

    let timeout = sleep(Duration::from_secs(timeout_seconds));
    tokio::pin!(timeout);

    let interrupted = wait_for_interrupt();
    tokio::pin!(interrupted);

    let exit_code = tokio::select! {
        result = &mut operation => match result {
            Ok(()) => 0,
            Err(error) => {
                log(format!("{error:#}"));
                1
            }
        },
        _ = &mut timeout => {
            log(format!("timed out pairing {address}"));
            124
        },
        _ = &mut interrupted => {
            log("interrupted");
            130
        },
    };

    agent.unregister().await;
    Ok(exit_code)
}

async fn find_device_path(
    connection: &Connection,
    address: &str,
) -> Result<Option<OwnedObjectPath>> {
    let manager = Proxy::new(connection, BLUEZ, "/", OBJECT_MANAGER_IFACE)
        .await
        .context("creating BlueZ ObjectManager proxy")?;
    let objects: ManagedObjects = manager
        .call("GetManagedObjects", &())
        .await
        .context("reading BlueZ managed objects")?;

    for (path, interfaces) in objects {
        let Some(properties) = interfaces.get(DEVICE_IFACE) else {
            continue;
        };

        let Some(value) = properties.get("Address") else {
            continue;
        };

        let Ok(device_address) = <&str>::try_from(value) else {
            continue;
        };

        if device_address.to_uppercase() == address {
            return Ok(Some(path));
        }
    }

    Ok(None)
}

async fn pair_trust_and_connect(
    connection: &Connection,
    device_path: OwnedObjectPath,
    address: String,
) -> Result<()> {
    let device = Proxy::new(connection, BLUEZ, device_path, DEVICE_IFACE)
        .await
        .context("creating BlueZ Device1 proxy")?;

    let paired: bool = device
        .get_property("Paired")
        .await
        .context("reading Device1.Paired")?;

    if !paired {
        log(format!("pairing {address}"));
        let _: () = device
            .call("Pair", &())
            .await
            .map_err(|error| anyhow!("pair failed for {address}: {error}"))?;
        log(format!("paired {address}"));
    }

    trust_and_connect(&device, &address).await
}

async fn trust_and_connect(device: &Proxy<'_>, address: &str) -> Result<()> {
    device
        .set_property("Trusted", true)
        .await
        .context("setting Device1.Trusted")?;

    let connected: bool = device
        .get_property("Connected")
        .await
        .context("reading Device1.Connected")?;
    if connected {
        log(format!("already connected: {address}"));
        return Ok(());
    }

    log(format!("connecting {address}"));
    let _: () = device
        .call("Connect", &())
        .await
        .map_err(|error| anyhow!("connect failed for {address}: {error}"))?;
    log(format!("connected {address}"));
    Ok(())
}

async fn wait_for_interrupt() {
    #[cfg(unix)]
    {
        use tokio::signal::unix::{signal, SignalKind};

        let mut terminate = signal(SignalKind::terminate()).expect("register SIGTERM handler");
        tokio::select! {
            _ = tokio::signal::ctrl_c() => {},
            _ = terminate.recv() => {},
        }
    }

    #[cfg(not(unix))]
    {
        let _ = tokio::signal::ctrl_c().await;
    }
}

fn log(message: impl AsRef<str>) {
    eprintln!("kitana-bluetooth-pair: {}", message.as_ref());
}
