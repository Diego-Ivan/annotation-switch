/* FormatSourceRow.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivan/annotation_switch/ui/format-source-row.ui")]
public class AnnotationSwitch.FormatSourceRow : Adw.ActionRow {
    [GtkChild]
    private unowned Gtk.Button select_file_button;

    private Format _format;
    private File _selected_file;

    public File? selected_file {
        get {
            return _selected_file;
        }
        private set {
            _selected_file = value;
        }
    }

    public Format format {
        get {
            return _format;
        }
        set {
            _format = value;
            selected_file = null;
            if (_format == null) {
                select_file_button.sensitive = false;
                notify_property ("format");
                return;
            }

            select_file_button.sensitive = true;
            switch (_format.source_type) {
            case FOLDER:
                title = _("Select Folder");
                break;
            case FILE:
                title = _("Select File");
                break;
            default:
                assert_not_reached ();
            }
        }
    }

    [GtkCallback]
    private async void on_select_file_clicked () 
    requires (format != null) {
        switch (format.source_type) {
        case FOLDER:
            yield handle_folder ();
            break;
        case FILE:
            yield handle_single_file ();
            break;
        }
    }

    private async void handle_folder () {
        var chooser = new Gtk.FileDialog () {
            modal = true
        };

        try {
            selected_file = yield chooser.select_folder ((Gtk.Window) root, null);
            FileInfo info = yield selected_file.query_info_async ("standard::name", NOFOLLOW_SYMLINKS, Priority.DEFAULT_IDLE);
            subtitle = @"$(info.get_name ())/";
        } catch (Error e) {
            warning (e.message);
        }
    }

    private async void handle_single_file () {
        var filters = new ListStore (typeof (Gtk.FileFilter));

        if (format.file_extension != null) {
            var filter = new Gtk.FileFilter ();
            filter.add_suffix (format.file_extension);
            filters.append (filter);
        }

        var file_chooser = new Gtk.FileDialog () {
            filters = filters,
            modal = true,
        };

        try {
            selected_file = yield file_chooser.open ((Gtk.Window) root, null);
            FileInfo info = yield selected_file.query_info_async ("standard::name", NOFOLLOW_SYMLINKS, Priority.DEFAULT_IDLE);
            subtitle = info.get_name ();
        } catch (Error e) {
            warning (e.message);
        }
    }
}