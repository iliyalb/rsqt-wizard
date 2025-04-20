use cstr::cstr;
use qmetaobject::prelude::*;
use std::path::{Path, PathBuf};
use std::fs;
use walkdir::WalkDir;
use std::thread;
use std::sync::{Arc, Mutex};

struct InstallProgress {
    current_file: String,
    progress: f64,
    complete: bool,
}

lazy_static::lazy_static! {
    static ref INSTALL_PROGRESS: Arc<Mutex<Option<InstallProgress>>> = Arc::new(Mutex::new(None));
}

#[derive(QObject, Default)]
struct Greeter {
    base: qt_base_class!(trait QObject),
    
    // Properties
    install_path: qt_property!(QString; NOTIFY install_path_changed),
    create_shortcut: qt_property!(bool; NOTIFY create_shortcut_changed),
    required_space: qt_property!(QString; NOTIFY required_space_changed),
    current_file: qt_property!(QString; NOTIFY current_file_changed),
    progress: qt_property!(f64; NOTIFY progress_changed),
    installation_complete: qt_property!(bool; NOTIFY installation_complete_changed),
    
    // Signals
    install_path_changed: qt_signal!(),
    create_shortcut_changed: qt_signal!(),
    required_space_changed: qt_signal!(),
    current_file_changed: qt_signal!(),
    progress_changed: qt_signal!(),
    installation_complete_changed: qt_signal!(),
    
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

    check_progress: qt_method!(fn check_progress(&mut self) {
        if let Ok(progress_guard) = INSTALL_PROGRESS.lock() {
            if let Some(progress) = progress_guard.as_ref() {
                // Update UI with current progress
                self.current_file = progress.current_file.clone().into();
                self.current_file_changed();
                self.progress = progress.progress;
                self.progress_changed();
                
                // Check if installation is complete
                if progress.complete {
                    self.installation_complete = true;
                    self.installation_complete_changed();
                }
            }
        }
    }),

    start_installation: qt_method!(fn start_installation(&mut self) {
        let source_dir = Path::new("data").to_path_buf();
        let dest_dir = PathBuf::from(self.install_path.to_string());
        
        // Count total files
        let total_files = WalkDir::new(&source_dir)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.file_type().is_file())
            .count();
            
        if total_files == 0 {
            self.installation_complete = true;
            self.installation_complete_changed();
            return;
        }

        // Initialize progress safely
        if let Ok(mut progress) = INSTALL_PROGRESS.lock() {
            *progress = Some(InstallProgress {
                current_file: String::new(),
                progress: 0.0,
                complete: false,
            });
        }

        // Clone necessary values for the thread
        let source_dir_thread = source_dir.clone();
        let dest_dir_thread = dest_dir.clone();
        let progress_arc = INSTALL_PROGRESS.clone();

        // Spawn worker thread
        thread::spawn(move || {
            if !dest_dir_thread.exists() {
                let _ = fs::create_dir_all(&dest_dir_thread);
            }

            let mut files_processed = 0;

            for entry in WalkDir::new(source_dir_thread) {
                if let Ok(entry) = entry {
                    let path = entry.path();
                    if path.is_file() {
                        let relative = path.strip_prefix(&source_dir).unwrap_or(path);
                        let target = dest_dir_thread.join(relative);

                        if let Some(parent) = target.parent() {
                            let _ = fs::create_dir_all(parent);
                        }

                        // Update progress safely
                        if let Ok(mut progress) = progress_arc.lock() {
                            if let Some(ref mut p) = *progress {
                                p.current_file = target.to_string_lossy().to_string();
                                p.progress = files_processed as f64 / total_files as f64 * 100.0;
                            }
                        }

                        // Copy file
                        let _ = fs::copy(path, &target);
                        files_processed += 1;

                        // Small delay to prevent UI freeze
                        thread::sleep(std::time::Duration::from_millis(10));
                    }
                }
            }

            // Mark as complete safely
            if let Ok(mut progress) = progress_arc.lock() {
                if let Some(ref mut p) = *progress {
                    p.complete = true;
                    p.progress = 100.0;
                }
            }
        });
    })
}

fn main() {
    qml_register_type::<Greeter>(cstr!("Greeter"), 1, 0, cstr!("Greeter"));
    let mut engine = QmlEngine::new();
    engine.load_file("src/WizardWindow.qml".into());
    engine.exec();
}