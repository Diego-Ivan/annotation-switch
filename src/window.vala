/* window.vala
 *
 * Copyright 2024 Diego Iván
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivan/annotation_switch/ui/window.ui")]
public class AnnotationSwitch.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Adw.ComboRow source_format_row;
    [GtkChild]
    private unowned Adw.ComboRow target_format_row;
    
    [GtkChild]
    private unowned Adw.PreferencesGroup additional_group;
    [GtkChild]
    private unowned FileChooserRow image_directory_row;
    [GtkChild]
    private unowned FileChooserRow mappings_row;
    
    [GtkChild]
    private unowned FileChooserRow source_row;
    [GtkChild]
    private unowned FileChooserRow target_row;
    [GtkChild]
    private unowned Gtk.Button convert_button;

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var registry = FormatRegistry.get_instance ();
        ListModel parseable_formats = registry.get_formats_with_parser ();
        ListModel serializable_formats = registry.get_formats_with_serializer ();

        source_format_row.expression = 
        target_format_row.expression = 
            new Gtk.PropertyExpression (typeof(Format), null, "name");;

        source_format_row.notify["selected"]
            .connect (() => change_formats (source_format_row, source_row));
        target_format_row.notify["selected"]
            .connect (() => change_formats (target_format_row, target_row));

        source_format_row.model = parseable_formats;
        target_format_row.model = serializable_formats;
    }

    private void change_formats (Adw.ComboRow combo_row, FileChooserRow filechooser_row) {
        var format = (Format) combo_row.selected_item;
        if (format == null) {
            return;
        }

        filechooser_row.source_type = format.source_type;
        switch (format.source_type) {
        case FILE:
            filechooser_row.title = _("Select a file");
            break;
        case FOLDER:
            filechooser_row.title = _("Select a folder");
            break;
        }

        var source_format = (Format) source_format_row.selected_item;
        var target_format = (Format) target_format_row.selected_item;

        if (source_format == null || target_format == null) {
            return;
        }

        RequiredTransformations transformations = check_format_compatibility ();

        /* Change visibility of widgets if they are needed or not */
        additional_group.visible = transformations != 0x0;
        image_directory_row.visible = LOOKUP_IMAGE in transformations;
        mappings_row.visible = NAME_TO_ID in transformations || ID_TO_NAME in transformations;

        if (transformations != 0x0) {
            convert_button.sensitive = false;
        }
    }

    private RequiredTransformations check_format_compatibility () {
        var source_format = (Format) source_format_row.selected_item;
        var target_format = (Format) target_format_row.selected_item;

        RequiredTransformations transforms = 0;
        check_normalization (source_format, target_format, ref transforms);
        check_source (source_format, target_format, ref transforms);
        check_mappings (source_format, target_format, ref transforms);

        return transforms;
    }

    private void check_normalization (Format source, Format target, ref RequiredTransformations transforms) {
        if (source.is_normalized == target.is_normalized) {
            return;
        }

        if (source.is_normalized && !target.is_normalized) {
            transforms |= NORMALIZE;
        } else {
            transforms |= DENORMALIZE;
        }

        transforms |= LOOKUP_IMAGE;
    }

    private void check_source (Format source, Format target, ref RequiredTransformations transforms) {
        if (source.contains_image_path == target.contains_image_path) {
            return;
        }
        if (!target.contains_image_path) {
            return;
        }
        
        transforms |= LOOKUP_IMAGE;
    }

    private void check_mappings (Format source, Format target, ref RequiredTransformations transforms) {
        if (source.class_format == target.class_format) {
            return;
        }

        if (source.class_format == NAME) {
            transforms |= NAME_TO_ID;
        } else {
            transforms |= ID_TO_NAME;
        }
    }

    [GtkCallback]
    private void on_convert_button_clicked () {
        message (@"$(check_format_compatibility ())");

        var parser = new Yolo5OBBParser ();
        var serializer = new Yolo5OBBSerializer ();

        try {
            parser.init (source_row.selected_file);
            serializer.init (target_row.selected_file, null);
        } catch (Error e) {
            critical (e.message);
        }

        while (parser.has_next ()) {
            try {
                Annotation? annotation = parser.get_next ();
                if (annotation == null) {
                    continue;
                }
                print(@"$annotation\n");
                serializer.push ((owned) annotation);
            } catch (Error e) {
                critical (e.message);
            }
        }

        try {
            serializer.finish ();
        } catch (Error e) {
            warning (e.message);
        }
    }
}