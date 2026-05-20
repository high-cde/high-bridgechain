mod config;
mod network;
mod consensus;
mod state;
mod zlang_vm;

use config::NodeConfig;
use network::Network;
use consensus::ConsensusEngine;
use state::State;
use zlang_vm::ZLangVm;
use rpc::server::RpcServer;

#[tokio::main]
async fn main() {
    println!("🚀 HighBridgeChain FULL node avviato");

    let cfg = NodeConfig::load_default();
    let mut state = State::load_genesis(&cfg.genesis_path);
    let vm = ZLangVm::new();
    let mut network = Network::new(&cfg);
    let mut consensus = ConsensusEngine::new(&cfg, &mut state, vm, &mut network);

    tokio::spawn(async move {
        RpcServer::start("127.0.0.1:8545").await;
    });

    consensus.run().await;
}
