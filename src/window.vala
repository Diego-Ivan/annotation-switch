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
    private Adw.ComboRow source_format_row;
    [GtkChild]
    private Adw.ComboRow target_format_row;

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var list_store = new ListStore (typeof (Format));
        list_store.splice(0, 0, {
            new Format ("Yolo V5 Oriented Bounding Boxes", FOLDER, NAME) {
                parser = new Yolo5OBBParser (),
                serializer = new Yolo5OBBSerializer ()
            },
        });

        var parser_filter = new Gtk.CustomFilter ((object) => ((Format) object).parser != null);
        var serializer_filter = new Gtk.CustomFilter ((object) => ((Format) object).serializer != null);

        var parser_filtered = new Gtk.FilterListModel (list_store, (owned) parser_filter);
        var serializer_filtered = new Gtk.FilterListModel (list_store, (owned) serializer_filter);

        var name_expression = new Gtk.PropertyExpression (typeof(Format), null, "name");

        source_format_row.expression = name_expression;
        target_format_row.expression = name_expression;

        source_format_row.model = parser_filtered;
        target_format_row.model = serializer_filtered;
    }
}
