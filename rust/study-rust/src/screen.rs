extern crate termion;

use std::io::{Write, Stdout};
use termion::cursor;
use termion::clear;
use termion::raw::{IntoRawMode, RawTerminal};
use termion::screen::{ToAlternateScreen, AlternateScreen};

pub struct Screen {
    pub stdout: AlternateScreen<RawTerminal<Stdout>>
}

impl Screen {

    pub fn new(stdout: Stdout) -> Screen {
        Screen {
            stdout: AlternateScreen::from(stdout.into_raw_mode().unwrap())
        }
    }

    pub fn write(&mut self, cursor: (u16, u16), content: &Vec<String>) {
        write!(self.stdout, "{}", clear::All).unwrap();
        for (i, row) in content.iter().enumerate() {
            write!(self.stdout, "{}", cursor::Goto(1, i as u16 + 1)).unwrap();
            write!(self.stdout, "{}", row).unwrap();
        }
        write!(self.stdout, "{}", cursor::Goto(cursor.0, cursor.1)).unwrap();
        self.stdout.flush().unwrap();
    }

    pub fn to_alternate_screen(&mut self) {
        write!(self.stdout, "{}", ToAlternateScreen).unwrap();
    }
}
