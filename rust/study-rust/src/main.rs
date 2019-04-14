extern crate termion;
extern crate rlua;

mod screen;
mod context;

use std::io::{stdin, stdout, Write, Read};
use std::fs::{File};
use std::path::Path;
use std::sync::{Arc, Mutex};
use termion::input::{TermRead};
use termion::event::Key;
use rlua::{Lua, Function, Context as LuaContext};
use context::{Context as AppContext, Mode};
use screen::{Screen};

fn main() {
    Lua::new().context(context);
}

fn context<'a>(lua_context: LuaContext<'a>) {
    let globals = lua_context.globals();
    let app_context = Arc::new(Mutex::new(AppContext::new()));
    let mut screen = Arc::new(Mutex::new(Screen::new(stdout())));

    let mut exited = false;
    let mut source = String::new();
    let mut f = File::open(Path::new("./runtime/main.lua")).unwrap();
    f.read_to_string(&mut source).unwrap();

    lua_context.load(&source).exec().unwrap();

    lua_context.scope(|scope| {
        let stdin = stdin();

        globals.set("get_cursor", scope.create_function(|ctx, ()| {
            let context = app_context.lock().unwrap();
            let table = ctx.create_table().unwrap();
            table.set(1, context.cursor.0).unwrap();
            table.set(2, context.cursor.1).unwrap();
            Ok(table)
        }).unwrap()).unwrap();

        globals.set("set_cursor", scope.create_function(|_, (col, row): (u16, u16)| {
            let mut context = app_context.lock().unwrap();
            let (max_col, max_row) = context.get_viewport();
            context.cursor.0 = match col {
                col if col >= max_col => max_col,
                col if col <= 1       => 1,
                col                   => col
            };
            context.cursor.1 = match row {
                row if row >= max_row => max_row,
                row if row <= 1       => 1,
                row                   => row
            };

            Ok(())
        }).unwrap()).unwrap();

        globals.set("input", scope.create_function(|_, (s): (String)| {
            let mut context = app_context.lock().unwrap();
            let (col, row) = (context.cursor.0 as usize - 1, context.cursor.1 as usize - 1);
            for _ in context.buffer.len()..row + 1 {
                context.buffer.push(String::new());
            }
            match context.buffer.get_mut(row) {
                Some(row) => {
                    for _ in row.len()..col + 1 {
                        row.push(' ');
                    }
                    row.insert(col, s.chars().nth(0).unwrap());
                },
                None => ()
            }
            context.cursor.0 = context.cursor.0 + 1;
            Ok(())
        }).unwrap()).unwrap();

        globals.set("delete", scope.create_function(|_, (): ()| {
            let mut context = app_context.lock().unwrap();
            let (col, row) = (context.cursor.0 as usize - 1, context.cursor.1 as usize - 1);
            match context.buffer.get_mut(row) {
                Some(row) => {
                    row.remove(col);
                },
                None => ()
            }
            context.cursor.0 = context.cursor.0 - 1;
            Ok(())
        }).unwrap()).unwrap();

        globals.set("set_mode", scope.create_function(|_, (mode): (String)| {
            let mut context = app_context.lock().unwrap();
            match Mode::from_str(&mode) {
                Some(mode) => context.mode = mode,
                None => ()
            };
            Ok(())
        }).unwrap()).unwrap();

        globals.set("get_mode", scope.create_function(|_, (): ()| {
            let context = app_context.lock().unwrap();
            Ok(context.mode.as_str().to_string())
        }).unwrap()).unwrap();

        globals.set("get_line", scope.create_function(|_, (row): (u16)| {
            let context = app_context.lock().unwrap();
            let line = context.buffer.get(row as usize).unwrap();
            Ok(line.clone())
        }).unwrap()).unwrap();

        globals.set("exit", scope.create_function(|_, (): ()| {
            let mut context = app_context.lock().unwrap();
            context.exit = true;
            Ok(())
        }).unwrap()).unwrap();

        let consume_input: Function = globals.get("consume_input").unwrap();

        for key in stdin.keys() {
            match key.unwrap() {
                Key::Esc => consume_input.call::<_, ()>("Esc").unwrap(),
                Key::Backspace => consume_input.call::<_, ()>("Backspace").unwrap(),
                Key::Insert => consume_input.call::<_, ()>("Insert").unwrap(),
                Key::Left => consume_input.call::<_, ()>("Left").unwrap(),
                Key::Right => consume_input.call::<_, ()>("Right").unwrap(),
                Key::Up => consume_input.call::<_, ()>("Up").unwrap(),
                Key::Down => consume_input.call::<_, ()>("Down").unwrap(),
                Key::Home => consume_input.call::<_, ()>("Home").unwrap(),
                Key::End => consume_input.call::<_, ()>("End").unwrap(),
                Key::PageUp => consume_input.call::<_, ()>("PageUp").unwrap(),
                Key::PageDown => consume_input.call::<_, ()>("PageDown").unwrap(),
                Key::Delete => consume_input.call::<_, ()>("Delete").unwrap(),
                Key::Char(c) => {
                    consume_input.call::<_, ()>(c.to_string()).unwrap();
                },
                Key::Ctrl(c) => {
                    consume_input.call::<_, ()>("Ctrl+".to_string() + &c.to_string()).unwrap();
                },
                Key::Alt(c) => {
                    consume_input.call::<_, ()>("Alt+".to_string() + &c.to_string()).unwrap();
                },
                _ => ()
            }
            {
                let context = app_context.lock().unwrap();
                match context.exit {
                    true => {
                        break;
                    },
                    false => {
                        screen.lock().unwrap().write(context.cursor, &context.buffer);
                    }
                }
            }
        }
        {
            screen.lock().unwrap().to_alternate_screen();
        }
    });
}

