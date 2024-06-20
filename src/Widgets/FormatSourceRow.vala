/* FormatSourceRow.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivan/annotation_switch/ui/format-source-row.ui")]
public class AnnotationSwitch.FormatSourceRow : Adw.ActionRow {
    private Format _format;

    public Format format {
        get {
            return _format;
        }
        set {
            _format = value;
        }
    }
}