use std::collections::HashMap;
use termion::event::{Key};
use rlua::{Function};

pub enum Mode {
    Normal,
    Insert
}

impl Mode {

    pub fn from_str(string: &str) -> Option<Mode> {
        match string {
            "Normal" => Some(Mode::Normal),
            "Insert" => Some(Mode::Insert),
            _ => None
        }
    }

    pub fn as_str(&self) -> &str {
        match self {
            Mode::Normal => "Normal",
            Mode::Insert => "Insert"
        }
    }

}

pub struct Context {

    pub mode: Mode,
    pub keys: HashMap<Key, Function<'static>>,
    pub buffer: Vec<String>,
    pub cursor: (u16, u16),
    pub exit: bool

}

unsafe impl Send for Context {}
unsafe impl Sync for Context {}

impl Context {
    pub fn new() -> Context {
        Context {
            mode: Mode::Normal,
            keys: HashMap::new(),
            buffer: vec![
                "test".to_string(),
                "      sample".to_string()
            ],
            exit: false,
            cursor: (1, 1)
        }
    }

    pub fn get_viewport(&self) -> (u16, u16) {
        termion::terminal_size().unwrap()
    }
}

