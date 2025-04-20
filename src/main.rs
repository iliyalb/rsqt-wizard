use cstr::cstr;
use qmetaobject::prelude::*;
use std::path::Path;
use walkdir::WalkDir;

#[derive(QObject, Default)]
struct Greeter {
    base: qt_base_class!(trait QObject),
    
    // Properties
    name: qt_property!(QString; NOTIFY name_changed),
    install_path: qt_property!(QString; NOTIFY install_path_changed),
    create_shortcut: qt_property!(bool; NOTIFY create_shortcut_changed),
    required_space: qt_property!(QString; NOTIFY required_space_changed),
    
    // Signals
    name_changed: qt_signal!(),
    install_path_changed: qt_signal!(),
    create_shortcut_changed: qt_signal!(),
    required_space_changed: qt_signal!(),
    
    // Methods
    compute_greetings: qt_method!(fn compute_greetings(&self, verb: String) -> QString {
        format!("{} {}", verb, self.name.to_string()).into()
    }),

    calculate_required_space: qt_method!(fn calculate_required_space(&mut self) -> QString {
        let data_path = Path::new("data");
        let size = if data_path.exists() {
            WalkDir::new(data_path)
                .into_iter()
                .filter_map(|entry| entry.ok())
                .filter_map(|entry| entry.metadata().ok())
                .filter(|metadata| metadata.is_file())
                .fold(0, |acc, m| acc + m.len())
        } else {
            0
        };
        
        let mb_size = (size as f64 / 1_048_576.0).ceil();
        self.required_space = format!("{:.0}", mb_size).into();
        self.required_space.clone()
    }),

    set_install_path: qt_method!(fn set_install_path(&mut self, path: String) {
        self.install_path = path.into();
        self.install_path_changed();
    }),

    browse_directory: qt_method!(fn browse_directory(&mut self) -> QString {
        if let Some(path) = native_dialog::FileDialog::new()
            .set_location(&std::env::current_dir().unwrap_or_default())
            .show_open_single_dir()
            .unwrap_or(None) 
        {
            let path_str = path.to_string_lossy().to_string();
            self.set_install_path(path_str.clone());
            return path_str.into();
        }
        self.install_path.clone()
    }),

    set_create_shortcut: qt_method!(fn set_create_shortcut(&mut self, create: bool) {
        self.create_shortcut = create;
        self.create_shortcut_changed();
    })
}

fn main() {
    qml_register_type::<Greeter>(cstr!("Greeter"), 1, 0, cstr!("Greeter"));
    let mut engine = QmlEngine::new();
    engine.load_file("src/WizardWindow.qml".into());
    engine.exec();
}