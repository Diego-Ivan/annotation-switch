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
    private unowned FileChooserRow source_row;
    [GtkChild]
    private unowned FileChooserRow target_row;

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var list_store = new ListStore (typeof (Format));
        list_store.splice(0, 0, {
            new Format ("Yolo V5 Oriented Bounding Boxes", FOLDER, NAME) {
                parser = new Yolo5OBBParser (), serializer = new Yolo5OBBSerializer (),
                file_extension = "txt", contains_image_path = false, named_after_image = true
            },
            new Format ("OIDV4", FOLDER, NAME) {
                parser = new OIDv4Parser (),
                file_extension = "txt", contains_image_path = false, is_normalized = false, named_after_image = true,
            },
        });

        var parser_filter = new Gtk.CustomFilter ((object) => ((Format) object).parser != null);
        var serializer_filter = new Gtk.CustomFilter ((object) => ((Format) object).serializer != null);

        var parser_filtered = new Gtk.FilterListModel (list_store, (owned) parser_filter);
        var serializer_filtered = new Gtk.FilterListModel (list_store, (owned) serializer_filter);

        var name_expression = new Gtk.PropertyExpression (typeof(Format), null, "name");

        source_format_row.expression = name_expression;
        target_format_row.expression = name_expression;

        source_format_row.notify["selected"].connect (() => {
            var format = (Format) source_format_row.selected_item;
            if (format == null) {
                return;
            }
            source_row.source_type = format.source_type;
        });

        target_format_row.notify["selected"].connect (() => {
            var format = (Format) source_format_row.selected_item;
            if (format == null) {
                return;
            }
            target_row.source_type = format.source_type;
        });

        source_format_row.model = parser_filtered;
        target_format_row.model = serializer_filtered;
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

        if (!source.contains_image_path) {
            transforms |= LOOKUP_IMAGE;
        }
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
        //  var source_format = (Format) source_format_row.selected_item;
        //  var target_format = (Format) target_format_row.selected_item;

        //  if (source_format.class_format != target_format.class_format) {
        //      warning (@"This transformation requires mapping from $(source_format.class_format) to $(target_format.class_format)");
        //  }

        //  var parser = new Yolo5OBBParser ();
        //  var serializer = new Yolo5OBBSerializer ();

        //  try {
        //      parser.init (source_row.selected_file);
        //      serializer.init (target_row.selected_file, null);
        //  } catch (Error e) {
        //      critical (e.message);
        //  }

        //  while (parser.has_next ()) {
        //      try {
        //          Annotation? annotation = parser.get_next ();
        //          if (annotation == null) {
        //              continue;
        //          }
        //          print(@"$annotation\n");
        //          serializer.push ((owned) annotation);
        //      } catch (Error e) {
        //          critical (e.message);
        //      }
        //  }

        //  try {
        //      serializer.finish ();
        //  } catch (Error e) {
        //      warning (e.message);
        //  }
    }
}