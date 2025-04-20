use cstr::cstr;
use qmetaobject::prelude::*;
use std::path::{Path, PathBuf};
use std::fs;
use walkdir::WalkDir;

#[derive(QObject, Default)]
struct Greeter {
    base: qt_base_class!(trait QObject),
    
    // Properties
    name: qt_property!(QString; NOTIFY name_changed),
    install_path: qt_property!(QString; NOTIFY install_path_changed),
    create_shortcut: qt_property!(bool; NOTIFY create_shortcut_changed),
    required_space: qt_property!(QString; NOTIFY required_space_changed),
    current_file: qt_property!(QString; NOTIFY current_file_changed),
    progress: qt_property!(f64; NOTIFY progress_changed),
    installation_complete: qt_property!(bool; NOTIFY installation_complete_changed),
    
    // Signals
    name_changed: qt_signal!(),
    install_path_changed: qt_signal!(),
    create_shortcut_changed: qt_signal!(),
    required_space_changed: qt_signal!(),
    current_file_changed: qt_signal!(),
    progress_changed: qt_signal!(),
    installation_complete_changed: qt_signal!(),
    
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
    }),

    start_installation: qt_method!(fn start_installation(&mut self) {
        let source_dir = Path::new("data");
        let dest_dir = PathBuf::from(self.install_path.to_string());
        
        // Count total files for progress calculation
        let total_files = WalkDir::new(source_dir)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_file())
            .count();
        
        let mut files_processed = 0;
        
        // Create destination directory if it doesn't exist
        if !dest_dir.exists() {
            let _ = fs::create_dir_all(&dest_dir);
        }
        
        // Copy files
        for entry in WalkDir::new(source_dir) {
            if let Ok(entry) = entry {
                let path = entry.path();
                if path.is_file() {
                    let relative = path.strip_prefix(source_dir).unwrap();
                    let target = dest_dir.join(relative);
                    
                    // Create parent directories if they don't exist
                    if let Some(parent) = target.parent() {
                        let _ = fs::create_dir_all(parent);
                    }
                    
                    // Update current file being processed
                    self.current_file = target.to_string_lossy().to_string().into();
                    self.current_file_changed();
                    
                    // Copy file
                    let _ = fs::copy(path, &target);
                    
                    // Update progress
                    files_processed += 1;
                    self.progress = (files_processed as f64 / total_files as f64) * 100.0;
                    self.progress_changed();
                }
            }
        }
        
        // Mark installation as complete
        self.installation_complete = true;
        self.installation_complete_changed();
    })
}

fn main() {
    qml_register_type::<Greeter>(cstr!("Greeter"), 1, 0, cstr!("Greeter"));
    let mut engine = QmlEngine::new();
    engine.load_file("src/WizardWindow.qml".into());
    engine.exec();
}