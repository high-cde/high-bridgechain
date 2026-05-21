pub mod config;
pub mod network;
pub mod consensus;
pub mod state;
pub mod zlang_vm;

use config::NodeConfig;
use network::Network;
use consensus::ConsensusEngine;
use state::State;
use zlang_vm::ZLangVm;
use rpc::server::start_rpc_server;

#[tokio::main]
async fn main() {
    println!("🚀 HighBridgeChain FULL node avviato");

    // Carica configurazione
    let cfg = NodeConfig::load_default();

    // Carica stato iniziale (genesis)
    let mut state = State::load_genesis(&cfg.genesis_path);

    // Inizializza VM
    let vm = ZLangVm::new();

    // Inizializza networking
    let mut network = Network::new(&cfg);

    // Inizializza consenso
    let mut consensus = ConsensusEngine::new(&cfg, &mut state, vm, &mut network);

    // Avvia RPC server
    tokio::spawn(async move {
        start_rpc_server("127.0.0.1:8545").await;
    });

    // Avvia consenso (loop principale)
    consensus.run().await;
}

echo "[7] Cargo build workspace"
cd "$ROOT"
cargo build

echo "[✔] HighBridgeChain fixed & built."
