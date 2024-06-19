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
    NAME,
}

public class AnnotationSwitch.Format : Object {
    public SourceType source_type { get; construct; default = FILE; }
    public string name { get; construct; default = ""; }
    public ClassFormat class_format { get; construct; default = NAME; }

    public Format (string name, SourceType source_type, ClassFormat class_format) {
        Object (
            name: name, 
            source_type: source_type, 
            class_format: class_format
        );
    }
}
