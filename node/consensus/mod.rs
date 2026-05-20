use crate::config::NodeConfig;
use crate::state::State;
use crate::zlang_vm::ZLangVm;
use crate::network::Network;
use protocol::block::Block;

pub struct ConsensusEngine<'a> {
    cfg: NodeConfig,
    state: &'a mut State,
    vm: ZLangVm,
    network: &'a mut Network,
}

impl<'a> ConsensusEngine<'a> {
    pub fn new(cfg: &NodeConfig, state: &'a mut State, vm: ZLangVm, network: &'a mut Network) -> Self {
        Self { cfg: cfg.clone(), state, vm, network }
    }

    pub async fn run(&mut self) {
        loop {
            let block = Block::empty(self.state.height + 1);
            self.state.apply_block(&block);

            let encoded = serde_json::to_vec(&block).unwrap();
            self.network.broadcast_block(encoded).await;

            println!("⛓️  Prodotto blocco {}", self.state.height);

            tokio::time::sleep(std::time::Duration::from_secs(10)).await;
        }
    }
}
