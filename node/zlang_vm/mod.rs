use serde_json::Value;

pub struct ZLangVm;

impl ZLangVm {
    pub fn new() -> Self {
        Self
    }

    pub fn execute(&self, script: &str, ctx: &Value) -> bool {
        println!("▶️ Esecuzione script ZLang: {}", script);
        true
    }
}
