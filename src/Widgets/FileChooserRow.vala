/* FileChooserRow.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivan/annotation_switch/ui/file-chooser-row.ui")]
public class AnnotationSwitch.FileChooserRow : Adw.ActionRow {
    private ListStore filter_store = new ListStore (typeof (Gtk.FileFilter));

    private SourceType _mode;
    public SourceType source_type {
        get {
            return _mode;
        }
        set {
            _mode = value;
            switch (_mode) {
            case FILE:
                title = _("Select File");
                break;
            case FOLDER:
                title = _("Select Folder");
                break;
            }
        }
    }

    private File _selected_file;
    public File? selected_file {
        get {
            return _selected_file;
        }
        set {
            _selected_file = value;
            if (value == null) {
                return;
            }
            update_filename.begin ();
        }
    }

    public ListModel filters {
        get {
            return filter_store;
        }
    }

    [GtkCallback]
    private async void choose_file () {
        var dialog = new Gtk.FileDialog () {
            modal = true,
            filters = this.filters,
        };

        try {
            switch (source_type) {
            case FILE:
                selected_file = yield dialog.open ((Gtk.Window) root, null);
                break;
            case FOLDER:
                selected_file = yield dialog.select_folder ((Gtk.Window) root, null);
                break;
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    private async void update_filename () {
        try {
            FileInfo? file_info = yield selected_file.query_info_async ("standard::name,standard::file-type", NOFOLLOW_SYMLINKS);
            this.subtitle = file_info.get_name ();
            if (selected_file.query_file_type (NOFOLLOW_SYMLINKS, null) == DIRECTORY) {
                this.subtitle += "/";
            }
        } catch (Error e) {
            critical (e.message);
        }
    }

    public void clear_filters () {
        filter_store.remove_all ();
    }

    public void add_filter (Gtk.FileFilter filter) {
        filter_store.append (filter);
    }
}

public enum AnnotationSwitch.FileChooserRowMode {
    FILE,
    FOLDER
}