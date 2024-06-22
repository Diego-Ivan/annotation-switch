/* Format.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public enum AnnotationSwitch.SourceType {
    FOLDER,
    FILE
}

public enum AnnotationSwitch.ClassFormat {
    ID,
    NAME;

    public string to_string () {
        switch (this) {
        case ID:
            // translators: this will be used in the following context: 'Transforming from Class ID to Class Name' and 'Transforming from Class Name to Class ID'
            return _("Class ID");
        case NAME:
            // translators: this will be used in the following context: 'Transforming from Class ID to Class Name' and 'Transforming from Class Name to Class ID'
            return _("Class Name");
        }
        assert_not_reached ();
    }
}

public class AnnotationSwitch.Format : Object {
    public SourceType source_type { get; construct; default = FILE; }
    public string name { get; construct; default = ""; }
    public string? file_extension { get; set; default = null; }

    /* Properties needed to configure the conversion pipeline */
    public bool contains_image_path { get; set; default = false; }
    public bool is_normalized { get; set; default = false; }
    public ClassFormat class_format { get; construct; default = NAME; }

    public FormatParser? parser { get; set; default = null; }
    public FormatSerializer? serializer { get; set; default = null; }

    public Format (string name, SourceType source_type, ClassFormat class_format) {
        Object (
            name: name, 
            source_type: source_type, 
            class_format: class_format
        );
    }
}
