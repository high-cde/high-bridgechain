use crate::zlang_parser::{parse, ZAst};

pub struct Vm;

impl Vm {
    pub fn new() -> Self {
        Vm
    }

    pub fn deploy(&self, _name: &str, _code: &str) -> Result<String, String> {
        Ok("contract deployed".to_string())
    }

    pub fn call(&self, _name: &str, _method: &str, _args: Vec<String>) -> Result<String, String> {
        Ok("call executed".to_string())
    }

    pub fn execute(&self, code: &str) -> Result<String, String> {
        let ast: ZAst = parse(code);
        Ok(format!("Executed {} tokens", ast.tokens.len()))
    }
}
