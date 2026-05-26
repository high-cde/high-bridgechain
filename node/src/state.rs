use crate::vm::Vm;

pub struct State {
    pub height: u64,
    pub vm: Vm,
}

impl State {
    pub fn new() -> Self {
        Self {
            height: 0,
            vm: Vm::new(),
        }
    }

    pub fn apply_block(&mut self, height: u64) {
        self.height = height;
    }
}
