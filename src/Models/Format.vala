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
    BOTH,
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
        case BOTH:
            return _("Class ID and Name");
        }
        assert_not_reached ();
    }
}

public class AnnotationSwitch.Format : Object {
    public string name { get; construct; default = ""; }
    public string id { get; construct; default = ""; }

    public Type parser_type { get; set; default = Type.INVALID; }
    public Type serializer_type { get; set; default = Type.INVALID; }
    
    /* Properties needed to configure the conversion pipeline */
    public string? file_extension { get; set; default = null; }
    public bool contains_image_path { get; set; default = false; }
    public bool named_after_image { get; set; default = false; }
    public bool is_normalized { get; set; default = false; }
    public bool contains_mapping { get; set; default = false; }
    public ClassFormat class_format { get; set; default = NAME; }
    public SourceType source_type { get; set; default = FILE; }

    public Format (string name, string id) {
        Object (
            name: name, 
            id: id
        );
    }
}
